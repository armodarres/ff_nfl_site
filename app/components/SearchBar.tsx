"use client";

import { useState, useMemo, useRef, useEffect } from "react";
import Link from "next/link";

interface Player {
  gsis_id: string;
  name: string;
  slug: string;
  position: string;
  team: string;
  active: boolean;
  jersey?: number | null;
  first_season: number;
  last_season: number;
}

// -------------------------
// Helpers
// -------------------------

function normalize(str: string): string {
  return str.toLowerCase().replace(/[^a-z0-9]/g, "");
}

function tokenize(name: string): string[] {
  return normalize(name).split(/[\s-]+/).filter(Boolean);
}

function buildInitials(name: string): string {
  const tokens = tokenize(name);
  const chars = tokens.map((t) => t[0]);
  return chars.join("");
}

// *** UPDATED HERE ***
function matchesQuery(playerName: string, query: string): boolean {
  const q = normalize(query);
  if (!q) return false;

  const n = normalize(playerName);
  const tokens = tokenize(playerName);
  const initials = buildInitials(playerName);


  // 2️⃣ token prefix match (keeps ian → NOT brian)
  for (const t of tokens) {
    if (t.startsWith(q)) return true;
  }

  // 3️⃣ initials match (jm → joe mixon)
  if (initials.startsWith(q)) return true;

  return false;
}

function filterPlayers(players: Player[], query: string): Player[] {
  if (!query) return [];
  return players
    .filter((p) => Boolean(p.active)) 
    .filter((p) => matchesQuery(p.name, query));
}

// -------------------------
// Component
// -------------------------

export default function SearchBar() {
  const [players, setPlayers] = useState<Player[]>([]);
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // load player data once
  useEffect(() => {
    fetch("/data/site_data/player_index.json?v=4", { cache: "no-store" })
      .then((res) => res.json())
      .then((data) => setPlayers(data))
      .catch((err) => console.error("Failed to load players:", err));
  }, []);

  const filteredPlayers = useMemo(() => {
    if (!players || players.length === 0) return [];
    const results = filterPlayers(players, query);
    return results.sort((a, b) => a.name.localeCompare(b.name));
  }, [players, query]);

  // close dropdown on outside click
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (!containerRef.current) return;
      if (!containerRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    window.addEventListener("mousedown", handleClick);
    return () => window.removeEventListener("mousedown", handleClick);
  }, []);

  // close dropdown on escape key
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    window.addEventListener("keydown", handleKey);
    return () => window.removeEventListener("keydown", handleKey);
  }, []);

  return (
    <div
      ref={containerRef}
      className="relative w-full max-w-md"
    >
      <input
        type="text"
        value={query}
        onChange={(e) => {
          setQuery(e.target.value);
          setOpen(true);
        }}
        onFocus={() => setOpen(true)}
        placeholder="Search players…"
        className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />

      {open && filteredPlayers.length > 0 && (
        <div
          className="
            absolute left-0 right-0 mt-1 
            max-h-80 overflow-y-auto 
            rounded-md border border-gray-300 bg-white shadow-lg z-50
          "
        >
          {filteredPlayers.map((player) => (
            <Link
              key={player.gsis_id}
              href={`/players/${player.slug}`}
              className="
                flex items-center gap-3 px-3 py-3 
                hover:bg-gray-100 cursor-pointer
              "
            >
              <img
                src={`/headshots/${player.gsis_id}.png`}
                alt={player.name}
                className="h-12 w-12 rounded-full object-contain bg-gray-200"
                loading="lazy"
                onError={(e) => {
                  (e.currentTarget as HTMLImageElement).src = "/headshots/missing.png";
                }}
              />

              <div className="flex flex-col">
                <span className="text-base font-semibold">{player.name}</span>
                <span className="text-sm text-gray-500">
                  {player.position} — {player.team}
                </span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
