export default function KartuPermintaan({ item }) {
  return (
    <div className="rounded-lg border border-gray-200 bg-white p-4 shadow-sm hover:shadow-md transition">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">{item.namaBarang}</h3>
        <span className="text-xs px-2 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200">{item.status}</span>
      </div>
      <div className="mt-3 grid grid-cols-2 gap-2 text-sm">
        <div className="">Total Kuantitas</div>
        <div className="text-right font-medium">{item.totalKuantitas} {item.unit}</div>
        <div className="">Jumlah Partisipan</div>
        <div className="text-right font-medium">{item.jumlahPartisipan}</div>
      </div>
    </div>
  );
}