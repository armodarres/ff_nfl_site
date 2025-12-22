export default function CoachPage({ params }: { params: { slug: string } }) {
  return (
    <div style={{ padding: 20, fontSize: "20px" }}>
      Coach Placeholder: {params.slug}
    </div>
  );
}
