export default function SnapWeekly({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>SnapWeekly</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
