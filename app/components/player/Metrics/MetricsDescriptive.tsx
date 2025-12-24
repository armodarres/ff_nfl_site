export default function MetricsDescriptive({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>MetricsDescriptive</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
