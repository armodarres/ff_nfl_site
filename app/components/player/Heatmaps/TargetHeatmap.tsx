export default function TargetHeatmap({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>TargetHeatmap</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
