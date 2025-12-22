"use client";

import { useEffect, useState } from "react";
import NavDropdown from "./NavDropdown";

type TeamIndexEntry = {
  team_abbr: string;
  name: string;
  slug: string;
  active: boolean;
};

type NavItem = {
  label: string;
  href: string;
  logo: string;
};

export default function TeamsDropdown() {
  const [items, setItems] = useState<NavItem[]>([]);

  useEffect(() => {
    fetch("/data/site_data/team_index.json")
      .then((res) => res.json())
      .then((data: TeamIndexEntry[]) => {
        if (!Array.isArray(data)) return;

        const activeTeams = data
          .filter(
            (t) =>
              t &&
              t.active &&
              typeof t.team_abbr === "string" &&
              typeof t.slug === "string"
          )
          .sort((a, b) => a.team_abbr.localeCompare(b.team_abbr));

        const mapped = activeTeams.map((t) => ({
          label: t.team_abbr,
          href: `/teams/${t.slug}`,
          logo: `/data/team_logos/${t.team_abbr}.png`,   // <<< HERE
        }));

        setItems(mapped);
      })
      .catch((err) => console.error("Failed to load team_index.json", err));
  }, []);

  return <NavDropdown label="Teams" items={items} />;
}
