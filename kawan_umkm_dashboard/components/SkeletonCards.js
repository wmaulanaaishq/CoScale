export default function SkeletonCards({ count = 4 }) {
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} className="animate-pulse rounded-xl border border-gray-200 bg-white p-5">
          <div className="flex items-start justify-between">
            <div className="h-5 w-40 rounded bg-gray-200" />
            <div className="h-6 w-20 rounded-full bg-gray-200" />
          </div>
          <div className="mt-4 grid grid-cols-3 gap-3">
            <div className="h-14 rounded bg-gray-100" />
            <div className="h-14 rounded bg-gray-100" />
            <div className="h-14 rounded bg-gray-100" />
          </div>
        </div>
      ))}
    </div>
  );
}