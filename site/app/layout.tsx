import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Weekkeep — A week worth keeping",
    template: "%s · Weekkeep",
  },
  description:
    "Weekkeep helps parents keep up to seven moments from the past week. Photo selection and share rendering happen on your iPhone; sharing starts only when you choose it.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
  openGraph: {
    title: "Weekkeep — A week worth keeping",
    description:
      "Keep up to seven moments from the last week. Photo selection and share rendering happen on your iPhone; sharing starts only when you choose it.",
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
