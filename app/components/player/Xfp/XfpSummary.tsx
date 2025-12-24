export default function XfpSummary({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>XfpSummary</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
