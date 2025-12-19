"use client";

import Link from "next/link";
import NavDropdown from "./components/NavDropdown";
import SearchBar from "./components/SearchBar";

export default function HomePage() {
  return (
    <main style={styles.page}>

      {/* HEADER */}
      <header style={styles.header}>
        <div style={styles.headerLeft}>
          <img
            src="/no-cap-logo.jpg"
            alt="No Cap Logo"
            style={styles.logo}
          />
          <h1 style={styles.headerTitle}>No Cap Fantasy</h1>
        </div>

        <SearchBar />
      </header>

      {/* NAV BAR */}
      <nav style={styles.nav}>
        <NavDropdown 
          label="Players"
          items={[
            { label: "QB", href: "/players/qb" },
            { label: "RB", href: "/players/rb" },
            { label: "WR", href: "/players/wr" },
            { label: "TE", href: "/players/te" },
          ]}
        />

        <NavDropdown 
          label="Teams"
          items={[
            { label: "All Teams", href: "/teams" },
          ]}
        />

        <NavDropdown 
          label="Coaches"
          items={[
            { label: "All Coaches", href: "/coaches" },
          ]}
        />

        <NavDropdown 
          label="Research"
          items={[
            { label: "Latest Posts", href: "/research" },
          ]}
        />

        <NavDropdown 
          label="Tools"
          items={[
            { label: "XFP Model", href: "/tools/xfp" },
          ]}
        />
      </nav>

      {/* HERO AREA */}
      <section style={styles.heroBox}>
        <h2 style={styles.heroTitle}>Landing Hero Area</h2>
      </section>

      {/* FEATURED */}
      <section style={styles.featuredRow}>
        <div style={styles.featureBox}>
          <h3 style={styles.featureTitle}>Featured Players</h3>
        </div>

        <div style={styles.featureBox}>
          <h3 style={styles.featureTitle}>Featured Research</h3>
        </div>
      </section>

    </main>
  );
}

//
// STYLES
//

const styles: Record<string, any> = {

  page: {
    minHeight: "100vh",
    background: "#f9f6ee",
    color: "#1e1e1e",
    fontFamily: "Inter, sans-serif",
    padding: 0,
  },

  header: {
    padding: "20px 40px",
    background: "#ffffffcc",
    borderBottom: "1px solid rgba(0,0,0,0.06)",
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
  },

  headerLeft: {
    display: "flex",
    alignItems: "center",
    gap: "16px",
  },

  logo: {
    width: "42px",
    height: "42px",
    objectFit: "contain",
  },

  headerTitle: {
    fontSize: "32px",
    fontWeight: 800,
    color: "#1a1a1a",
    letterSpacing: "-0.5px",
  },

  nav: {
    display: "flex",
    justifyContent: "space-between",
    padding: "12px 50px",
    borderBottom: "1px solid rgba(0,0,0,0.06)",
    background: "#fffefacc",
    fontSize: "18px",
    fontWeight: 700,
  },

  heroBox: {
    width: "85%",
    margin: "60px auto 40px",
    padding: "40px",
    background: "#ffffffaa",
    borderRadius: "8px",
    border: "1px solid rgba(0,0,0,0.08)",
  },

  heroTitle: {
    fontSize: "36px",
    opacity: 0.9,
    fontWeight: 700,
  },

  featuredRow: {
    display: "flex",
    justifyContent: "center",
    gap: "40px",
    marginTop: "40px",
  },

  featureBox: {
    width: "420px",
    height: "260px",
    background: "#ffffffaa",
    borderRadius: "8px",
    border: "1px solid rgba(0,0,0,0.08)",
    padding: "20px",
  },

  featureTitle: {
    fontSize: "24px",
    opacity: 0.9,
    fontWeight: 700,
  },
};

if (typeof document !== "undefined") {
  const sheet = document.styleSheets[0];
  sheet.insertRule(
    `
    a:hover {
      background: rgba(0,0,0,0.05);
      cursor: pointer;
    }
  `,
    sheet.cssRules.length
  );
}
