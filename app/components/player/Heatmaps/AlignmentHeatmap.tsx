export default function AlignmentHeatmap({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>AlignmentHeatmap</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
