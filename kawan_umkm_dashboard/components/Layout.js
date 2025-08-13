import Link from "next/link";

export default function Layout({ children }) {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="border-b bg-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
          <Link href="/" className="flex items-center space-x-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600 text-white">KU</div>
            <span className="text-lg font-semibold">Kawan UMKM</span>
          </Link>
          <nav className="flex items-center space-x-4 text-sm">
            <Link className="text-gray-700 hover:text-blue-600" href="/">Dasbor</Link>
            <Link className="text-gray-700 hover:text-blue-600" href="/umkm">UMKM</Link>
            <Link className="text-gray-700 hover:text-blue-600" href="/pembayaran">Pembayaran</Link>
          </nav>
        </div>
      </header>
      <main className="mx-auto max-w-6xl px-6 py-6">
        {children}
      </main>
      <footer className="mt-10 border-t bg-white">
        <div className="mx-auto max-w-6xl px-6 py-6 text-xs text-gray-500">MVP Kawan UMKM — Aggregasi permintaan kolektif untuk UMKM.</div>
      </footer>
    </div>
  );
}