"use client";

import Link from "next/link";
import playerIndex from "@/data/site_data/players/index.json";

const positions = ["QB", "RB", "WR", "TE"];

export default function PlayersPage() {
  return (
    <main style={{ padding: "20px" }}>
      <h1>Players</h1>

      <div className="menuRoot">
        <div className="menuItem">
          Players
          <div className="submenu">
            {positions.map((pos) => {
              const players = playerIndex.filter((p) => p.pos === pos);

              return (
                <div key={pos} className="submenuItem">
                  {pos}
                  <div className="subsubmenu">
                    {players.map((pl) => (
                      <Link
                        key={pl.slug}
                        href={`/players/${pl.slug}`}
                        className="playerLink"
                      >
                        {pl.name}
                      </Link>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      <style jsx>{`
        .menuRoot {
          margin-top: 20px;
          position: relative;
          display: inline-block;
        }

        .menuItem {
          background: #222;
          color: white;
          padding: 10px 20px;
          border-radius: 6px;
          cursor: pointer;
          position: relative;
        }

        .submenu {
          display: none;
          position: absolute;
          top: 100%;
          left: 0;
          background: #333;
          padding: 10px;
          border-radius: 6px;
          min-width: 120px;
          z-index: 50;
        }

        .menuItem:hover .submenu {
          display: block;
        }

        .submenuItem {
          padding: 6px 12px;
          color: white;
          position: relative;
          white-space: nowrap;
        }

        .submenuItem:hover {
          background: #444;
        }

        .subsubmenu {
          /* HIDDEN BY DEFAULT */
          display: none;

          position: absolute;
          top: 0;
          left: 100%;
          background: #444;
          padding: 6px;
          border-radius: 6px;
          min-width: 180px;
          max-width: 220px;
          max-height: 300px;
          overflow-y: auto;
          z-index: 100;

          /* STACK VERTICALLY WHEN SHOWN */
          flex-direction: column;
        }

        .submenuItem:hover .subsubmenu {
          display: flex;
        }

        .playerLink {
          padding: 6px 12px;
          color: white;
          text-decoration: none;
          display: block;
          white-space: normal;
          line-height: 1.2;
          border-bottom: 1px solid #555;
        }

        .playerLink:last-child {
          border-bottom: none;
        }

        .playerLink:hover {
          background: #555;
        }
      `}</style>
    </main>
  );
}
