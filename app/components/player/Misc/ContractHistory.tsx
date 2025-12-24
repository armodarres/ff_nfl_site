export default function ContractHistory({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>ContractHistory</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
