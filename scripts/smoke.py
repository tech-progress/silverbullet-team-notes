import hashlib
import http.cookiejar
import json
import os
import subprocess
import urllib.error
import urllib.request
from pathlib import Path


BASE = f"http://127.0.0.1:{os.environ['LOCAL_PORT']}"
ADMIN = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))


def request(path, method="GET", data=None, token=None, admin=False, expected=(200,)):
    headers = {"Origin": BASE, "X-Sync-Mode": "true"}
    if isinstance(data, dict):
        headers["Content-Type"] = "application/json"
        data = json.dumps(data).encode()
    if token:
        headers["Authorization"] = f"Bearer {token}"
    opener = ADMIN if admin else urllib.request.build_opener()
    try:
        response = opener.open(urllib.request.Request(BASE + path, data=data, method=method, headers=headers), timeout=30)
    except urllib.error.HTTPError as error:
        response = error
    body = response.read()
    assert response.code in expected, (method, path, response.code, body[:300])
    return body


def compose(*args, input_data=None):
    return subprocess.run(["docker", "compose", *args], input=input_data, check=True, stdout=subprocess.PIPE, timeout=900).stdout


def verify_tokens(tokens, attachment):
    for name, token in tokens.items():
        assert request(f"/{name}/.fs/Handbook.md", token=token) == f"Private {name} handbook".encode()
        assert hashlib.sha256(request(f"/{name}/.fs/attachment.txt", token=token)).hexdigest() == hashlib.sha256(attachment).hexdigest()
        other = "beta" if name == "alpha" else "alpha"
        request(f"/{other}/.fs/Handbook.md", token=token, expected=(401, 403, 404))
        request(f"/{name}/.fs/Handbook.md", expected=(401, 403, 404))


login = json.loads(request("/.dashboard/api/login", "POST", {"username": os.environ["SB_ADMIN_USER"], "password": os.environ["SB_ADMIN_PASSWORD"]}, admin=True))
assert login["status"] == "ok"
admin_token = json.loads(request(f"/.dashboard/api/admin/users/{os.environ['SB_ADMIN_USER']}/tokens", "POST", {"name": "runtime-qualification"}, admin=True))["token"]
request("/team/.runtime/lua", "POST", b"return 1", token=admin_token, expected=(503,))
tokens = {}
attachment = b"retained attachment qualification bytes\n"
for name in ("alpha", "beta"):
    request("/.dashboard/api/admin/users", "POST", {"username": name, "password": os.urandom(16).hex(), "admin": False}, admin=True, expected=(200, 201))
    tokens[name] = json.loads(request(f"/.dashboard/api/admin/users/{name}/tokens", "POST", {"name": "qualification"}, admin=True))["token"]
    request("/.dashboard/api/admin/spaces", "POST", {"name": name, "binding": {"prefix": f"/{name}"}, "access": "none", "members": {name: {"role": "write", "runtimeApi": False}}, "shell": {"enabled": False}}, admin=True)
    request(f"/{name}/.fs/Handbook.md", "PUT", f"Private {name} handbook".encode(), token=tokens[name])
    request(f"/{name}/.fs/attachment.txt", "PUT", attachment, token=tokens[name])
verify_tokens(tokens, attachment)
compose("exec", "-T", "app", "/bin/sh", "-ec", "! command -v chromium && ! command -v chromium-browser && ! command -v google-chrome")
print("PASS: generated administrator; two account tokens; separate private spaces; cross-space and anonymous denial; attachment bytes; no Chromium; Runtime API returns 503")
compose("restart", "app")
compose("up", "-d", "--wait", "--wait-timeout", "300")
verify_tokens(tokens, attachment)
print("PASS: notes, attachments, accounts and API tokens survive restart")
compose("stop", "app")
snapshot = compose("run", "--rm", "--no-deps", "-T", "--entrypoint", "/bin/tar", "app", "-czf", "-", "-C", "/data", ".")
Path(".local/full-data.tgz").write_bytes(snapshot)
compose("down", "--volumes")
compose("run", "--rm", "--no-deps", "-T", "--entrypoint", "/bin/tar", "app", "-xzf", "-", "-C", "/data", input_data=snapshot)
compose("up", "-d", "--wait", "--wait-timeout", "300")
verify_tokens(tokens, attachment)
print("PASS: full data-root restore into a newly created empty volume retains access rules and bytes")
