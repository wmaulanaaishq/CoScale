import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Http "mo:base/Http";

actor {
  public type Permintaan = {
    id: Nat;
    namaBarang: Text;
    totalKuantitas: Nat;
    unit: Text;
    jumlahPartisipan: Nat;
    status: Text;
  };

  stable var permintaanDaftar : [Permintaan] = [];

  public query func getPermintaan() : async [Permintaan] {
    permintaanDaftar
  };

  public func tambahPermintaan(permintaan : Permintaan) : async () {
    var found : Bool = false;
    let updated : [Permintaan] = Array.tabulate<Permintaan>(
      permintaanDaftar.size(),
      func(i : Nat) : Permintaan {
        let p = permintaanDaftar[i];
        if (p.id == permintaan.id) {
          found := true;
          permintaan
        } else {
          p
        }
      }
    );

    if (found) {
      permintaanDaftar := updated;
    } else {
      permintaanDaftar := Array.append<Permintaan>(permintaanDaftar, [permintaan]);
    };
  };

  public func resetData() : async () {
    permintaanDaftar := [];
  };

  func permintaanToJSON(p : Permintaan) : Text {
    "{" #
    "\"id\":" # Nat.toText(p.id) # "," #
    "\"namaBarang\":\"" # p.namaBarang # "\"," #
    "\"totalKuantitas\":" # Nat.toText(p.totalKuantitas) # "," #
    "\"unit\":\"" # p.unit # "\"," #
    "\"jumlahPartisipan\":" # Nat.toText(p.jumlahPartisipan) # "," #
    "\"status\":\"" # p.status # "\"" #
    "}"
  };

  func joinWithComma(arr : [Text]) : Text {
    var result : Text = "";
    var first : Bool = true;
    for (t in Iter.fromArray(arr)) {
      if (first) {
        result := t;
        first := false;
      } else {
        result := result # "," # t;
      };
    };
    result
  };

  public query func http_request(req : Http.Request) : async Http.Response {
    let url : Text = req.url;
    if (Text.contains(url, #text "permintaan")) {
      let itemsText : [Text] = Array.map<Permintaan, Text>(permintaanDaftar, permintaanToJSON);
      let bodyText : Text = "[" # joinWithComma(itemsText) # "]";
      {
        status_code = 200;
        headers = [
          ("Content-Type", "application/json"),
          ("Access-Control-Allow-Origin", "*")
        ];
        body = Text.encodeUtf8(bodyText);
        streaming_strategy = null;
      }
    } else {
      {
        status_code = 200;
        headers = [
          ("Content-Type", "text/plain"),
          ("Access-Control-Allow-Origin", "*")
        ];
        body = Text.encodeUtf8("Kawan UMKM Backend aktif");
        streaming_strategy = null;
      }
    }
  };
}