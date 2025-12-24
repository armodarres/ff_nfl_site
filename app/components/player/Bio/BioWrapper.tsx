"use client";

import { useBio } from "./BioContext";

export default function BioWrapper({ children }: { children: React.ReactNode }) {
  const { bioOpen } = useBio();

  return (
    <div
      style={{
        display: "flex",
        transition: "margin-left 0.25s ease",
        marginLeft: bioOpen ? 420 : 0,
      }}
    >
      {children}
    </div>
  );
}
