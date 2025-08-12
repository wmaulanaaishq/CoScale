export default function KartuPermintaan({ item }) {
  return (
    <div className="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">{item.namaBarang}</h3>
        <span className="inline-flex items-center rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">
          {item.status}
        </span>
      </div>
      <div className="mt-2 text-sm text-gray-700">
        <div className="mt-1">Total Kuantitas: <span className="font-medium">{item.totalKuantitas} {item.unit}</span></div>
        <div className="mt-1">Jumlah Partisipan: <span className="font-medium">{item.jumlahPartisipan}</span></div>
      </div>
    </div>
  );
}