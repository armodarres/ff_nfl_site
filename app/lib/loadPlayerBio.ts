import fs from "fs";
import path from "path";

export function loadPlayerBio(gsis_id: string): string {
  const bioPath = path.join(process.cwd(), "content", "players", `${gsis_id}.md`);
  if (fs.existsSync(bioPath)) {
    return fs.readFileSync(bioPath, "utf8");
  }
  return ""; // no bio available
}
