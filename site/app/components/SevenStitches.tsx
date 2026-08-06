const stitchColors = [
  "#E97A68",
  "#E39455",
  "#E5A84B",
  "#66836E",
  "#5F879B",
  "#686286",
  "#8A6386",
];

export function SevenStitches({ compact = false }: { compact?: boolean }) {
  return (
    <span
      aria-hidden="true"
      className={compact ? "seven-stitches seven-stitches--compact" : "seven-stitches"}
    >
      {stitchColors.map((color, index) => (
        <span key={index} className="stitch" style={{ backgroundColor: color }} />
      ))}
    </span>
  );
}
