export default function DepthChartTimeline({ data }: { data: any }) {
  return (
    <div style={{ padding: 20 }}>
      <h2>DepthChartTimeline</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
