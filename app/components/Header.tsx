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
    status,
    height,
    weight,
    draft_team,
    draft_pick,
    team_colors,
  } = data;

  // local headshots live in /public/headshots
  const headshotSrc = `/headshots/${gsis_id}.png`;

  // jersey_number can be null/NA; only show if valid
  const jersey =
    jersey_number === null ||
    jersey_number === undefined ||
    jersey_number === "" ||
    Number.isNaN(Number(jersey_number))
      ? ""
      : ` #${jersey_number}`;

  // team logo path (your actual folder)
  const teamLogoSrc = team ? `/data/team_logos/${team}.png` : null;

  return (
    <div style={{ marginBottom: 50 }}>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 20,
          background: team_colors?.primary || "#333",
          padding: 20,
          borderRadius: 10,
          color: "white",
        }}
      >
        <img
          src={headshotSrc}
          alt={name}
          style={{
            width: 120,
            height: 120,
            borderRadius: 10,
            border: "2px solid white",
            objectFit: "cover",
          }}
        />

        <div style={{ lineHeight: 1.35 }}>
          <h1 style={{ margin: 0, fontSize: 32 }}>{name}</h1>

          <h2 style={{ margin: "6px 0 0 0", fontSize: 20, opacity: 0.95 }}>
            {(team || "FA")} — {pos || "UNK"}
            {jersey}
          </h2>

          <p style={{ marginTop: 10, marginBottom: 4, opacity: 0.9 }}>
            Age: {age ?? "—"} • Season {season ?? "—"} • {status ?? "—"}
          </p>

          <p style={{ margin: 0, opacity: 0.9 }}>
            Height: {height ?? "—"} • Weight: {weight ?? "—"} lbs
          </p>

          <p style={{ margin: "6px 0 0 0", opacity: 0.9 }}>
            College: {college ?? "—"}
          </p>

          {(draft_team || draft_pick) && (
            <p style={{ margin: "6px 0 0 0", opacity: 0.9 }}>
              Draft: {draft_team ?? "—"}
              {draft_pick ? `, Pick ${draft_pick}` : ""}
            </p>
          )}
        </div>

        {teamLogoSrc && (
          <div style={{ marginLeft: "auto" }}>
            <img src={teamLogoSrc} alt={team} style={{ height: 60 }} />
          </div>
        )}
      </div>
    </div>
  );
}
