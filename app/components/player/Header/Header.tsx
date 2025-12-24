"use client";

export default function Header({ data }: { data: any }) {
  const {
    name,
    team,
    pos,
    gsis_id,
    age,
    season,
    college,
    jersey_number,
    height,
    weight,
    draft_team,
    draft_pick,
    years_exp,
    highest_finish,
    avg_finish,
    archetype,
    team_colors,
  } = data;

  const primary = team_colors?.primary || "#333";
  const secondary = team_colors?.secondary || "#666";

  // Height conversion
  const feet = height ? Math.floor(height / 12) : null;
  const inches = height ? height % 12 : null;

  // Draft conversion
  const round = draft_pick ? Math.ceil(draft_pick / 32) : null;
  const pickInRound = draft_pick ? ((draft_pick - 1) % 32) + 1 : null;

  return (
    <div
      style={{
        position: "relative",
        marginBottom: 50,
        borderRadius: 12,
        overflow: "hidden",
        background: `linear-gradient(135deg, ${primary} 0%, ${secondary} 100%)`,
        boxShadow: "0 10px 25px rgba(0,0,0,0.25)",
        color: "white",
      }}
    >
      {/* Team watermark */}
      {team && (
        <img
          src={`/data/team_logos/${team}.png`}
          alt=""
          onError={(e) => (e.currentTarget.src = "/data/team_logos/missing.png")}
          style={{
            position: "absolute",
            right: 20,
            top: 20,
            height: 120,
            opacity: 0.15,
            filter: "grayscale(40%)",
          }}
        />
      )}

      <div style={{ display: "flex", padding: 30, gap: 30 }}>
        {/* Headshot */}
        <img
          src={`/headshots/${gsis_id}.png`}
          alt={name}
          onError={(e) => (e.currentTarget.src = "/headshots/missing.png")}
          style={{
            width: 160,
            height: 160,
            borderRadius: 12,
            objectFit: "cover",
            border: "3px solid white",
            boxShadow: "0 6px 20px rgba(0,0,0,0.35)",
          }}
        />

        {/* Info */}
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <h1 style={{ margin: 0, fontSize: 42, fontWeight: 700 }}>
              {name}
            </h1>

            <span
              style={{
                background: "rgba(255,255,255,0.18)",
                padding: "4px 10px",
                borderRadius: 6,
                fontSize: 18,
                fontWeight: 600,
              }}
            >
              {pos}
              {jersey_number ? ` · #${jersey_number}` : ""}
            </span>
          </div>

          <p style={{ margin: "6px 0 0 0", opacity: 0.95, fontSize: 18 }}>
            {team} • Age {age} • Season {season}
          </p>

          {/* DETAIL GRID */}
          <div
            style={{
              display: "flex",
              gap: 25,
              marginTop: 18,
              flexWrap: "wrap",
              fontSize: 16,
            }}
          >
            <span>🎓 {college ?? "—"}</span>

            {height && (
              <span>
                📏 {feet}'{inches}"
              </span>
            )}

            {weight && <span>⚖️ {weight} lbs</span>}

            {round && (
              <span>
                📝 Round {round}, Pick {pickInRound} ({draft_team})
              </span>
            )}

            {years_exp && <span>⏳ {years_exp} Yrs Exp</span>}

            {/* Archetype */}
            <span>🧬 Archetype: {archetype ?? "NA"}</span>

            {/* Best finish */}
            <span>🏆 Best Finish: {highest_finish ?? "NA"}</span>

            {/* Average finish */}
            <span>📈 Avg Finish: {avg_finish ?? "NA"}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
