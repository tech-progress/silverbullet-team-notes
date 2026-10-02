import { readFileSync } from "node:fs";
import { defineRailway, project, service, volume } from "railway/iac";

const defaults: Record<string, Record<string, string>> = JSON.parse(readFileSync(new URL("../template-defaults.json", import.meta.url), "utf8"));
const descriptions: Record<string, Record<string, string>> = JSON.parse(readFileSync(new URL("../template-descriptions.json", import.meta.url), "utf8"));
const repo = process.env.TEMPLATE_SOURCE_REPO;
const branch = process.env.TEMPLATE_SOURCE_BRANCH;
if (!repo || !branch || branch.includes("/")) throw new Error("Set TEMPLATE_SOURCE_REPO to an accessible owner/repository and TEMPLATE_SOURCE_BRANCH to an existing slash-free release channel; no distribution repository is assumed.");
const rootDirectory = process.env.TEMPLATE_SOURCE_ROOT_DIR ?? "/silverbullet-team-notes";

export default defineRailway(() => {
  const resolve = (name: string) => Object.fromEntries(Object.entries(defaults[name]).map(([key, value]) => [key, value.startsWith("${{secret(") ? { generator: value.slice(3, -2), preserveExisting: true, description: descriptions[name][key] } : { value, description: descriptions[name][key] }]));
  const appData = volume("Application Data", { sizeMB: 5000 });
  const app = service("SilverBullet", {
    source: { type: "github", repo, branch, rootDirectory },
    build: { builder: "DOCKERFILE", dockerfilePath: "Dockerfile" },
    healthcheck: "/.instance",
    healthcheckTimeout: 600,
    env: resolve("SilverBullet"),
    volumeMounts: { "/data": appData },
  });
  return project("SilverBullet team notes", { resources: [app, appData] });
});
