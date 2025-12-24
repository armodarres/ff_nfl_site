export default function XfpWeekly({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>XfpWeekly</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
