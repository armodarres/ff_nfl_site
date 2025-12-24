export default function SnapSituational({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>SnapSituational</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
