"use client";

import { useMemo, useState, useEffect } from "react";
import { useBio } from "./BioContext";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";

function previewText(text: string, maxChars = 450) {
  if (!text) return "";
  const clean = text.replace(/\n+/g, " ").trim();
  if (clean.length <= maxChars) return clean;
  return clean.slice(0, maxChars).trim() + "…";
}

export default function Bio({ name, text }: { name: string; text: string }) {
  const { setBioOpen } = useBio();
  const [open, setOpen] = useState(false);

  const preview = useMemo(() => previewText(text), [text]);

  useEffect(() => {
    setBioOpen(open);
  }, [open, setBioOpen]);

  if (!text) return null;

  return (
    <>
      {/* ========================================================= */}
      {/* COLLAPSED PREVIEW CARD — updated button position + label  */}
      {/* ========================================================= */}
      {!open && (
        <div style={{ marginTop: 18, maxWidth: 920 }}>
          <div
            style={{
              background: "#1a1a1a",
              border: "1px solid #2a2a2a",
              borderRadius: 12,
              padding: 22,
              boxShadow: "0 4px 12px rgba(0,0,0,0.25)",
              position: "relative",
            }}
          >
            {/* Title */}
            <div
              style={{
                fontWeight: 700,
                fontSize: 16,
                color: "#f5f5f5",
                marginBottom: 6,
              }}
            >
              Bio
            </div>

            {/* Preview text */}
            <p
              style={{
                margin: 0,
                lineHeight: 1.55,
                fontSize: 15.5,
                color: "#e0e0e0",
                paddingRight: 80, // spacing so text doesn’t touch button
              }}
            >
              {preview}
            </p>

            {/* BUTTON — moved to BOTTOM RIGHT */}
            <button
              onClick={() => setOpen(true)}
              style={{
                position: "absolute",
                right: 16,
                bottom: 14,
                border: "none",
                background: "rgba(255,255,255,0.08)",
                padding: "6px 12px",
                borderRadius: 8,
                cursor: "pointer",
                fontWeight: 600,
                color: "#fafafa",
              }}
            >
              More
            </button>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* FULL SLIDE-OUT PANEL (dark theme + markdown)              */}
      {/* ========================================================= */}
      {open && (
        <div
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            bottom: 0,
            width: 420,
            background: "#111",
            borderRight: "1px solid #222",
            boxShadow: "6px 0 20px rgba(0,0,0,0.35)",
            zIndex: 1000,
            display: "flex",
            flexDirection: "column",
            transition: "transform 0.25s ease-in-out",
          }}
        >
          {/* PANEL HEADER */}
          <div
            style={{
              padding: 20,
              borderBottom: "1px solid #222",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              gap: 12,
            }}
          >
            <div>
              <div style={{ fontWeight: 800, fontSize: 17, color: "#fafafa" }}>
                {name}
              </div>
              <div style={{ opacity: 0.5, fontSize: 13, color: "#ccc" }}>
                Player Bio
              </div>
            </div>

            <button
              onClick={() => setOpen(false)}
              style={{
                border: "none",
                background: "rgba(255,255,255,0.08)",
                padding: "8px 12px",
                borderRadius: 10,
                cursor: "pointer",
                fontWeight: 700,
                color: "#fafafa",
              }}
            >
              Close
            </button>
          </div>

          {/* MARKDOWN BODY */}
          <div
            style={{
              padding: 22,
              overflowY: "auto",
              color: "#e9e9e9",
              fontSize: 15,
              lineHeight: 1.6,
            }}
          >
            <ReactMarkdown
              remarkPlugins={[remarkGfm]}
              components={{
                h1: ({ children }) => (
                  <h1 style={{ fontSize: 26, marginTop: 25, color: "#fff" }}>
                    {children}
                  </h1>
                ),
                h2: ({ children }) => (
                  <h2 style={{ fontSize: 22, marginTop: 25, color: "#fafafa" }}>
                    {children}
                  </h2>
                ),
                h3: ({ children }) => (
                  <h3 style={{ fontSize: 18, marginTop: 20, color: "#eee" }}>
                    {children}
                  </h3>
                ),
                p: ({ children }) => (
                  <p style={{ margin: "10px 0", color: "#e0e0e0" }}>
                    {children}
                  </p>
                ),
                ul: ({ children }) => (
                  <ul
                    style={{
                      marginLeft: 20,
                      marginTop: 10,
                      marginBottom: 10,
                      color: "#ddd",
                      listStyleType: "disc",
                    }}
                  >
                    {children}
                  </ul>
                ),
                li: ({ children }) => (
                  <li style={{ marginBottom: 6 }}>{children}</li>
                ),
                strong: ({ children }) => (
                  <strong style={{ fontWeight: 700, color: "#fff" }}>
                    {children}
                  </strong>
                ),
                em: ({ children }) => (
                  <em style={{ color: "#ccc" }}>{children}</em>
                ),
                blockquote: ({ children }) => (
                  <blockquote
                    style={{
                      borderLeft: "3px solid #555",
                      paddingLeft: 12,
                      marginLeft: 0,
                      color: "#ccc",
                      fontStyle: "italic",
                    }}
                  >
                    {children}
                  </blockquote>
                ),
              }}
            >
              {text}
            </ReactMarkdown>
          </div>
        </div>
      )}
    </>
  );
}
