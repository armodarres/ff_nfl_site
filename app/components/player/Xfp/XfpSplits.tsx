export default function XfpSplits({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>XfpSplits</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
