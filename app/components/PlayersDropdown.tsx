"use client";

import Link from "next/link";
import { useState } from "react";

export default function PlayersDropdown() {
  const [open, setOpen] = useState(false);
  const [openHistorical, setOpenHistorical] = useState(false);

  return (
    <div
      style={styles.container}
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => {
        setOpen(false);
        setOpenHistorical(false);
      }}
    >
      <Link href="/players" style={styles.label}>
  Players
</Link>


      {open && (
        <div style={styles.dropdown}>
          {/* ACTIVE */}
          <Link href="/players/qb" style={styles.item}>QB</Link>
          <Link href="/players/rb" style={styles.item}>RB</Link>
          <Link href="/players/wr" style={styles.item}>WR</Link>
          <Link href="/players/te" style={styles.item}>TE</Link>

          <div
            style={styles.item}
            onMouseEnter={() => setOpenHistorical(true)}
            onMouseLeave={() => setOpenHistorical(false)}
          >
            Historical ▸

            {openHistorical && (
              <div style={styles.subDropdown}>
                <Link href="/players/historical/qb" style={styles.itemSmall}>QB</Link>
                <Link href="/players/historical/rb" style={styles.itemSmall}>RB</Link>
                <Link href="/players/historical/wr" style={styles.itemSmall}>WR</Link>
                <Link href="/players/historical/te" style={styles.itemSmall}>TE</Link>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// -------------------------
// STYLES
// -------------------------

const styles: Record<string, any> = {
  container: {
    position: "relative",
    padding: "12px 18px",
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
    padding: "6px 0px",
    zIndex: 999,
    minWidth: "180px",
  },

  item: {
    display: "block",
    padding: "6px 16px",
    fontSize: "15px",
    textDecoration: "none",
    color: "#222",
    whiteSpace: "nowrap",
    cursor: "pointer",
  },

  subDropdown: {
    position: "absolute",
    top: "50%",               // ↓ drop the menu lower
    left: "100%",             // → show to the right
    transform: "translateY(-10%)",  // ↓ slight visual centering
    background: "#fff",
    border: "1px solid rgba(0,0,0,0.08)",
    borderRadius: "6px",
    boxShadow: "0 0 12px rgba(0,0,0,0.08)",
    padding: "6px 0px",
    minWidth: "140px",
    zIndex: 999,
  },


  itemSmall: {
    display: "block",
    padding: "6px 12px",
    fontSize: "14px",
    textDecoration: "none",
    color: "#222",
    whiteSpace: "nowrap",
  },
};
