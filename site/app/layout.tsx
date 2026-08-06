import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Weekkeep — A week worth keeping",
    template: "%s · Weekkeep",
  },
  description:
    "Weekkeep helps parents turn the last week on their iPhone into a small album of up to seven photos—privately, on device.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
  openGraph: {
    title: "Weekkeep — A week worth keeping",
    description:
      "Turn the last week into a small album of up to seven photos. Your photos stay on your iPhone.",
    type: "website",
    images: [{ url: "/og.png", width: 1200, height: 630 }],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
