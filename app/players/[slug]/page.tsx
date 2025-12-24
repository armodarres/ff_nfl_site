export const dynamic = "force-static";

import fs from "fs";
import path from "path";
import playerIndex from "@/data/site_data/players/index.json";

import Header from "@/app/components/player/Header/Header";
import Bio from "@/app/components/player/Bio/Bio";

import { BioProvider } from "@/app/components/player/Bio/BioContext";
import BioWrapper from "@/app/components/player/Bio/BioWrapper";

import { loadPlayerBio } from "@/app/lib/loadPlayerBio";

export default async function PlayerPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;


  // -------------------------
  // Find player in index
  // -------------------------
  const player = playerIndex.find((p) => p.slug === slug);

  if (!player) {
    return (
      <main style={{ padding: 20 }}>
        <h1>Player not found</h1>
      </main>
    );
  }

  // -------------------------
  // Load the player's JSON
  // -------------------------
  const jsonPath = path.join(
    process.cwd(),
    "data/site_data/players",
    `player_id=${player.player_id}`,
    "player.json"
  );

  const raw = fs.readFileSync(jsonPath, "utf8");
  const data = JSON.parse(raw);

  // -------------------------
  // Load Markdown bio text
  // -------------------------
  const bioText = loadPlayerBio(data.gsis_id);

  // -------------------------
  // Render full page
  // -------------------------
  return (
    <BioProvider>
      <BioWrapper>
        <main
          style={{
            maxWidth: 1200,
            margin: "0 auto",
            padding: 20,
            display: "flex",
            flexDirection: "column",
            gap: 60,
          }}
        >
          {/* HEADER */}
          <Header data={data} />

          {/* BIO (collapsed + slide-out) */}
          <Bio name={data.name} text={bioText} />

          {/* SECTION LABELS */}
          <SectionLabel title="XFP Summary" />
          <SectionLabel title="XFP Splits" />
          <SectionLabel title="XFP Weekly" />
          <SectionLabel title="XFP WOWY" />
          <SectionLabel title="XFP Environment" />

          <SectionLabel title="Snap Rates – Weekly" />
          <SectionLabel title="Snap Rates – Situational" />
          <SectionLabel title="Route Participation" />

          <SectionLabel title="Metrics – Efficiency" />
          <SectionLabel title="Metrics – Descriptive" />
          <SectionLabel title="Heatmap – Targets" />
          <SectionLabel title="Heatmap – Alignment" />

          <SectionLabel title="Injury Timeline" />
          <SectionLabel title="Contract History" />
          <SectionLabel title="Depth Chart Timeline" />
        </main>
      </BioWrapper>
    </BioProvider>
  );
}

// -------------------------
// Typed Section Label
// -------------------------
function SectionLabel({ title }: { title: string }) {
  return (
    <div style={{ borderBottom: "1px solid #ccc", paddingBottom: 10 }}>
      <h2 style={{ margin: 0, opacity: 0.8 }}>{title}</h2>
    </div>
  );
}
