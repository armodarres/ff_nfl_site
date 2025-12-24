"use client";

import { createContext, useContext, useState } from "react";

interface BioContextType {
  bioOpen: boolean;
  setBioOpen: (open: boolean) => void;
}

const BioContext = createContext<BioContextType>({
  bioOpen: false,
  setBioOpen: () => {},
});

export function BioProvider({ children }: { children: React.ReactNode }) {
  const [bioOpen, setBioOpen] = useState(false);

  return (
    <BioContext.Provider value={{ bioOpen, setBioOpen }}>
      {children}
    </BioContext.Provider>
  );
}

export function useBio() {
  return useContext(BioContext);
}
