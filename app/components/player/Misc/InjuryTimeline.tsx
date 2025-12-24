export default function InjuryTimeline({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>InjuryTimeline</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
