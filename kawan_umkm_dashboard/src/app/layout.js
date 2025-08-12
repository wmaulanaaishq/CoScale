import "@/styles/globals.css";

export const metadata = {
  title: "Kawan UMKM Dashboard",
  description: "Dashboard permintaan kolektif on-chain (ICP)",
};

export default function RootLayout({ children }) {
  return (
    <html lang="id">
      <body className="bg-gray-50 text-gray-900">{children}</body>
    </html>
  );
}