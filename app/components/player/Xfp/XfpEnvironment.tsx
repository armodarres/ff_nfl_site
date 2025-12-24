export default function XfpEnvironment({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>XfpEnvironment</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
