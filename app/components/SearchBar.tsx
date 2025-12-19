"use client";

import { useState, useEffect } from "react";
import Link from "next/link";

export default function SearchBar() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<any[]>([]);
  const [playerIndex, setPlayerIndex] = useState<any[]>([]);

  // Load JSON once
  useEffect(() => {
    fetch("/data/site_data/player_index.json")
      .then((res) => res.json())
      .then((data) => setPlayerIndex(data));
  }, []);

  // Filter results
  useEffect(() => {
    if (!query) {
      setResults([]);
      return;
    }

    const q = query.toLowerCase();

    const matches = playerIndex
      .filter((p) => p.name.toLowerCase().includes(q))
      .slice(0, 8); // top 8 results

    setResults(matches);
  }, [query, playerIndex]);

  return (
    <div style={styles.container}>
      <input
        type="text"
        placeholder="Search players..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        style={styles.input}
      />

      {results.length > 0 && (
        <div style={styles.dropdown}>
          {results.map((p) => (
            <Link
              key={p.slug}
              href={`/players/${p.slug}`}
              style={styles.result}
              onClick={() => setQuery("")}
            >
              <img
                src={p.team_logo}
                style={{ width: "22px", height: "22px", marginRight: "8px" }}
              />
              {p.name} <span style={styles.pos}>({p.position})</span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}

//
// styles
//

const styles: Record<string, any> = {
  container: {
    position: "relative",
  },
  input: {
    width: "260px",
    padding: "10px 14px",
    borderRadius: "6px",
    fontSize: "15px",
    border: "1px solid rgba(0,0,0,.15)",
    outline: "none",
  },
  dropdown: {
    position: "absolute",
    top: "45px",
    left: 0,
    width: "260px",
    background: "#fff",
    border: "1px solid rgba(0,0,0,0.12)",
    borderRadius: "6px",
    boxShadow: "0 3px 10px rgba(0,0,0,0.1)",
    zIndex: 50,
  },
  result: {
    display: "flex",
    alignItems: "center",
    padding: "10px 12px",
    textDecoration: "none",
    color: "#111",
    fontSize: "15px",
  },
  pos: {
    opacity: 0.6,
    marginLeft: "4px",
    fontSize: "14px",
  },
};
