export const dynamic = "force-static";

import playerIndex from "@/data/site_data/players/index.json";
import fs from "fs";
import path from "path";

export default async function PlayerPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {

  const { slug } = await params;

  const player = playerIndex.find((p) => p.slug === slug);

  if (!player) {
    return (
      <main style={{ padding: "20px" }}>
        <h1>Player not found</h1>
      </main>
    );
  }

  const playerId = player.player_id;

  const filePath = path.join(
    process.cwd(),
    "data/site_data/players",
    `player_id=${playerId}`,
    "player.json"
  );

  const raw = fs.readFileSync(filePath, "utf8");
  const data = JSON.parse(raw);

  return (
    <main style={{ padding: "20px" }}>
      <h1>{data.name}</h1>
      <h2>{data.pos}</h2>

      <section style={{ marginTop: "30px" }}>
        <h3>Career totals</h3>
        <pre>{JSON.stringify(data.career, null, 2)}</pre>
      </section>

      <section style={{ marginTop: "30px" }}>
        <h3>Season history</h3>
        <pre>{JSON.stringify(data.season, null, 2)}</pre>
      </section>
    </main>
  );
}
