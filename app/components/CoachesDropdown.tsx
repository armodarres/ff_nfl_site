"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

type CoachEntry = {
  coach_id: string;
  name: string;
  slug: string;
  team: string;
  role: string;
  active: boolean;
};

type TeamEntry = {
  team_abbr: string;
  name: string;
  slug: string;
  active: boolean;
};

export default function CoachesDropdown() {
  const [teams, setTeams] = useState<TeamEntry[]>([]);
  const [coaches, setCoaches] = useState<CoachEntry[]>([]);
  const [hover, setHover] = useState(false);
  const [openTeam, setOpenTeam] = useState<string | null>(null);

  useEffect(() => {
    fetch("/data/site_data/team_index.json")
      .then((res) => res.json())
      .then((data: TeamEntry[]) => {
        if (!Array.isArray(data)) return;
        const actives = data
          .filter((t) => t.active)
          .sort((a, b) => a.team_abbr.localeCompare(b.team_abbr));
        setTeams(actives);
      })
      .catch((err) => console.error("Failed to load teams", err));
  }, []);

  useEffect(() => {
    fetch("/data/site_data/coach_index.json")
      .then((res) => res.json())
      .then((data: CoachEntry[]) => {
        if (!Array.isArray(data)) return;
        setCoaches(data);
      })
      .catch((err) => console.error("Failed to load coaches", err));
  }, []);

  const coachSorter = (a: CoachEntry, b: CoachEntry) => {
    const rank = (role: string) => {
      if (role === "HC") return 0;
      if (role === "AC") return 1;
      return 2;
    };
    const rA = rank(a.role);
    const rB = rank(b.role);
    if (rA !== rB) return rA - rB;
    return a.name.localeCompare(b.name);
  };

  return (
    <div
      style={styles.container}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => {
        setHover(false);
        setOpenTeam(null);
      }}
    >
      <Link href="/coaches" style={styles.label}>
  Coaches
</Link>


      {hover && (
        <div style={styles.dropdown}>

          {teams.map((team) => {
            const isOpen = openTeam === team.team_abbr;
            return (
              <div
                key={team.team_abbr}
                style={styles.item}
                onMouseEnter={() => setOpenTeam(team.team_abbr)}
              >
                <img
                  src={`/data/team_logos/${team.team_abbr}.png`}
                  alt={team.team_abbr}
                  style={styles.logo}
                />
                {team.team_abbr}

                {isOpen && (
                  <div style={styles.subDropdown}>
                    {coaches
                      .filter(
                        (c) =>
                          c.team === team.team_abbr &&
                          c.active === true
                      )
                      .sort(coachSorter)
                      .map((c) => (
                        <Link
                          key={c.slug}
                          href={`/coaches/${c.slug}`}
                          style={styles.subItem}
                        >
                          {c.name} ({c.role})
                        </Link>
                      ))}
                  </div>
                )}
              </div>
            );
          })}

          <Link
            href="/coaches/historical"
            style={styles.historical}
            onMouseEnter={() => setOpenTeam(null)}
          >
            Historical Coaches
          </Link>
        </div>
      )}
    </div>
  );
}

const styles: Record<string, any> = {
  container: {
    position: "relative",
    padding: "12px 14px",
  },

  label: {
    fontSize: "18px",
    fontWeight: 700,
    cursor: "pointer",
    color: "#111",
  },

  dropdown: {
    position: "absolute",
    top: "100%",
    left: 0,
    background: "#fff",
    border: "1px solid rgba(0,0,0,0.08)",
    borderRadius: "6px",
    boxShadow: "0 0 12px rgba(0,0,0,0.08)",
    padding: "2px 0px",
    zIndex: 999,

    minWidth: "160px", // tightened
    maxWidth: "160px",
  },

  item: {
    display: "flex",
    alignItems: "center",
    gap: "6px",       // tightened
    padding: "1.5px 10px", // tightened
    fontSize: "13px", // tightened
    lineHeight: "1",  // tightened
    color: "#222",
    whiteSpace: "nowrap",
    cursor: "pointer",
    position: "relative",
  },

  logo: {
    width: "16px",
    height: "16px",
    objectFit: "contain",
    flexShrink: 0,
  },

  subDropdown: {
    position: "absolute",
    top: "-40px",
    left: "100%",
    background: "#fff",
    border: "1px solid rgba(0,0,0,0.08)",
    borderRadius: "6px",
    boxShadow: "0 0 12px rgba(0,0,0,0.08)",
    padding: "4px 0px",
    minWidth: "200px",
    zIndex: 999,
  },

  subItem: {
    display: "block",
    padding: "6px 12px",
    fontSize: "13px",
    textDecoration: "none",
    color: "#222",
    whiteSpace: "nowrap",
  },

  historical: {
    display: "block",
    padding: "6px 10px",
    fontSize: "12px",
    textDecoration: "none",
    borderTop: "1px solid rgba(0,0,0,0.08)",
    color: "#444",
    marginTop: "2px",
    whiteSpace: "nowrap",
    cursor: "pointer",
  },
};
