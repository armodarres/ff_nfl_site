"use client";

import Link from "next/link";
import { useState } from "react";

interface DropdownItem {
  label: string;
  href: string;
  logo?: string;  // <<< HERE
}

interface DropdownProps {
  label: string;
  items: DropdownItem[];
}

export default function NavDropdown({ label, items }: DropdownProps) {
  const [open, setOpen] = useState(false);

  return (
    <div
      style={styles.container}
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => setOpen(false)}
    >
      <Link href={`/${label.toLowerCase()}`} style={styles.label}>
  {label}
</Link>


      {open && (
        <div style={styles.dropdown}>
          {items.map((item) => (
            <Link key={item.href} href={item.href} style={styles.item}>
              {item.logo && (
                <img
                  src={item.logo}
                  alt=""
                  style={styles.logo}
                />
              )}
              {item.label}
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}

const styles: Record<string, any> = {
  container: {
    position: "relative",
    padding: "12px 14px",
    whiteSpace: "nowrap",
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
    padding: "4px 0px",
    zIndex: 999,
    minWidth: "140px",
  },

  item: {
    display: "flex",
    alignItems: "center",
    gap: "6px",
    padding: "1.5px 10px",
    fontSize: "13px",
    lineHeight: 1.1,
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

  logo: {
    width: "16px",
    height: "16px",
    objectFit: "contain",
    flexShrink: 0,
  },
};
