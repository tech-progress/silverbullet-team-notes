import copy
import json
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def read(name):
    return json.loads((ROOT / name).read_text())


def graph_services():
    output = subprocess.check_output([str(ROOT / "node_modules/.bin/railway-iac-ts"), ".railway/railway.ts"], cwd=ROOT)
    graph = json.loads(output)
    if not graph.get("ok"):
        raise RuntimeError("IaC evaluation failed")
    return {resource["name"]: resource for resource in graph["graph"]["resources"] if resource["type"] == "service"}


def restore(draft, graph):
    result = copy.deepcopy(draft)
    config = result.get("data", {}).get("template", {}).get("serializedConfig", result)
    defaults = read("template-defaults.json")
    descriptions = read("template-descriptions.json")
    volumes = read("template-volumes.json")
    networking = read("template-networking.json")
    services = config["services"]
    if {service["name"] for service in services.values()} != set(graph):
        raise ValueError("Exact service set mismatch; refuse to create IDs or merge an unrelated draft")
    for service in services.values():
        name = service["name"]
        desired = graph[name]
        service["source"] = {key: value for key, value in desired["source"].items() if key != "type"}
        service["build"] = desired.get("build")
        service["deploy"] = desired.get("deploy") or {}
        service["variables"] = {key: {"defaultValue": value, "description": descriptions[name][key], "isOptional": False} for key, value in defaults[name].items()}
        mounts = service.get("volumeMounts", {})
        if name in volumes:
            if len(mounts) != 1:
                raise ValueError(f"{name}: create exactly one real draft volume before restoring")
            for mount in mounts.values():
                mount.update(volumes[name])
        elif mounts:
            raise ValueError(f"{name}: unexpected volume")
        public_port = networking[name].get("publicPort")
        service["networking"] = {"serviceDomains": {"<hasDomain>": {"port": public_port}} if public_port else {}, "tcpProxies": {}}
    return result


def main():
    mode = sys.argv[1]
    graph = graph_services()
    if mode == "self-test":
        draft = {"services": {name: {"name": name, "volumeMounts": {"test-only-existing-volume": {}}} for name in graph}}
        canonical = restore(draft, graph)
        assert restore(canonical, graph) == canonical
        altered = copy.deepcopy(canonical)
        next(iter(altered["services"].values()))["source"] = {"image": "incorrect"}
        assert restore(altered, graph) != altered
        print("PASS: offline draft canonicalization, mutation detection, idempotence")
        return
    draft = json.loads(Path(sys.argv[2]).read_text())
    canonical = restore(draft, graph)
    if mode == "restore":
        Path(sys.argv[3]).write_text(json.dumps(canonical, indent=2) + "\n")
        print("Prepared offline JSON only; nothing uploaded, deployed or published")
    elif mode == "audit":
        if draft != canonical:
            raise SystemExit("FAIL: source, build, health, variables, volumes or networking differs; restore offline then review")
        print("PASS: exported draft matches the local contract. Remote source accessibility is not proven.")
    else:
        raise SystemExit("Unknown mode")


if __name__ == "__main__":
    main()
