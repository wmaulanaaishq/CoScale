import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor {
  public type Permintaan = {
    id: Nat;
    namaBarang: Text;
    totalKuantitas: Nat;
    unit: Text;
    jumlahPartisipan: Nat;
    status: Text;
  };

  stable var permintaanList : [Permintaan] = [];

  public query func getPermintaan() : async [Permintaan] {
    return permintaanList;
  };

  public func tambahPermintaan(permintaanBaru: Permintaan) : async () {
    // If the id exists, update entry; else append
    var found = false;
    let updated = Array.tabulate<Permintaan>(permintaanList.size(), func(i) {
      let p = permintaanList[i];
      if (p.id == permintaanBaru.id) {
        found := true;
        return permintaanBaru;
      } else {
        return p;
      }
    });
    if (found) {
      permintaanList := updated;
    } else {
      permintaanList := Array.append<Permintaan>(permintaanList, [permintaanBaru]);
    };
  };

  public func resetData() : async () {
    permintaanList := [];
  };
}