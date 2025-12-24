export default function MetricsEfficiency({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>MetricsEfficiency</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
