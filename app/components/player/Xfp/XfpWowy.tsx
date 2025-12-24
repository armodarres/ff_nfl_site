export default function XfpWowy({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>XfpWowy</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
