import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "MedX Provider Portal",
  description: "Advanced Healthcare AI Platform",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased min-h-screen flex flex-col">
        {children}
      </body>
    </html>
  );
}
