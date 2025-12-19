"use client";

import Link from "next/link";
import { useState } from "react";

interface DropdownProps {
  label: string;
  items: { label: string; href: string }[];
}

export default function NavDropdown({ label, items }: DropdownProps) {
  const [open, setOpen] = useState(false);

  return (
    <div
      style={styles.container}
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => setOpen(false)}
    >
      <span style={styles.label}>{label}</span>

      {open && (
        <div style={styles.dropdown}>
          {items.map((item) => (
            <Link key={item.href} href={item.href} style={styles.item}>
              {item.label}
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}

//
// STYLES
//

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
    padding: "8px 0px",
    zIndex: 999,
    minWidth: "160px",
  },

  item: {
    display: "block",
    padding: "10px 16px",
    fontSize: "15px",
    textDecoration: "none",
    color: "#222",
  },
};
