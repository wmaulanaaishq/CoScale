import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Http "mo:base/Http";

actor {
  // ===== Types =====
  public type Permintaan = {
    id: Nat;
    namaBarang: Text;
    totalKuantitas: Nat;
    unit: Text;
    jumlahPartisipan: Nat;
    status: Text;
  };

  public type Umkm = {
    id: Nat;
    namaUsaha: Text;
    lokasi: Text;
  };

  public type Kebutuhan = {
    id: Nat;
    umkmId: Nat;
    namaBarang: Text;
    kuantitas: Nat;
    unit: Text;
    lokasi: Text;
    status: Text; // e.g., "DIAJUKAN", "TERGABUNG", "SELESAI"
  };

  public type Notifikasi = {
    id: Nat;
    pesan: Text;
  };

  public type Escrow = {
    id: Nat;
    permintaanId: Nat;
    totalTarget: Nat;
    totalTerkumpul: Nat;
    status: Text; // e.g., "MENUNGGU_DEPOSIT", "TERKUNCI", "DILEPASKAN"
  };

  // ===== Stable State =====
  stable var permintaanDaftar : [Permintaan] = [];

  stable var umkmDaftar : [Umkm] = [];
  stable var nextUmkmId : Nat = 1;

  stable var kebutuhanDaftar : [Kebutuhan] = [];
  stable var nextKebutuhanId : Nat = 1;

  stable var notifikasiDaftar : [Notifikasi] = [];
  stable var nextNotifId : Nat = 1;

  stable var escrowDaftar : [Escrow] = [];
  stable var nextEscrowId : Nat = 1;

  // ===== Queries (Read) =====
  public query func getPermintaan() : async [Permintaan] { permintaanDaftar };
  public query func getUmkm() : async [Umkm] { umkmDaftar };
  public query func getKebutuhan() : async [Kebutuhan] { kebutuhanDaftar };
  public query func getNotifikasi() : async [Notifikasi] { notifikasiDaftar };
  public query func getEscrow() : async [Escrow] { escrowDaftar };

  // ===== Updates (Write) =====
  public func tambahPermintaan(permintaan : Permintaan) : async () {
    var found : Bool = false;
    let updated : [Permintaan] = Array.tabulate<Permintaan>(
      permintaanDaftar.size(),
      func(i : Nat) : Permintaan {
        let p = permintaanDaftar[i];
        if (p.id == permintaan.id) {
          found := true;
          permintaan
        } else { p } }
    );
    if (found) {
      permintaanDaftar := updated;
    } else {
      permintaanDaftar := Array.append<Permintaan>(permintaanDaftar, [permintaan]);
    };
  };

  public func resetData() : async () {
    permintaanDaftar := [];
    kebutuhanDaftar := [];
    notifikasiDaftar := [];
    escrowDaftar := [];
    // Reset counters for deterministic testing
    nextKebutuhanId := 1;
    nextNotifId := 1;
    nextEscrowId := 1;
  };

  public func registerUmkm(namaUsaha : Text, lokasi : Text) : async Nat {
    let id = nextUmkmId;
    nextUmkmId += 1;
    umkmDaftar := Array.append<Umkm>(umkmDaftar, [{ id; namaUsaha; lokasi }]);
    id
  };

  public func updateUmkm(umkm : Umkm) : async () {
    var found : Bool = false;
    let updated : [Umkm] = Array.tabulate<Umkm>(
      umkmDaftar.size(),
      func(i : Nat) : Umkm {
        let u = umkmDaftar[i];
        if (u.id == umkm.id) { found := true; umkm } else { u }
      }
    );
    if (found) { umkmDaftar := updated } else {
      // If not found, append (id should be unique; test helper behavior)
      umkmDaftar := Array.append<Umkm>(umkmDaftar, [umkm]);
    };
  };

  public func buatKebutuhan(umkmId : Nat, namaBarang : Text, kuantitas : Nat, unit : Text, lokasi : Text) : async Nat {
    let id = nextKebutuhanId;
    nextKebutuhanId += 1;
    let baru : Kebutuhan = { id; umkmId; namaBarang; kuantitas; unit; lokasi; status = "DIAJUKAN" };
    kebutuhanDaftar := Array.append<Kebutuhan>(kebutuhanDaftar, [baru]);
    id
  };

  public func updateKebutuhan(k : Kebutuhan) : async () {
    var found : Bool = false;
    let updated : [Kebutuhan] = Array.tabulate<Kebutuhan>(
      kebutuhanDaftar.size(),
      func(i : Nat) : Kebutuhan {
        let x = kebutuhanDaftar[i];
        if (x.id == k.id) { found := true; k } else { x }
      }
    );
    if (found) { kebutuhanDaftar := updated } else {
      kebutuhanDaftar := Array.append<Kebutuhan>(kebutuhanDaftar, [k]);
    };
  };

  public func tambahNotifikasi(pesan : Text) : async Nat {
    let id = nextNotifId;
    nextNotifId += 1;
    notifikasiDaftar := Array.append<Notifikasi>(notifikasiDaftar, [{ id; pesan }]);
    id
  };

  public func createEscrow(permintaanId : Nat, totalTarget : Nat) : async Nat {
    let id = nextEscrowId;
    nextEscrowId += 1;
    let e : Escrow = { id; permintaanId; totalTarget; totalTerkumpul = 0; status = "MENUNGGU_DEPOSIT" };
    escrowDaftar := Array.append<Escrow>(escrowDaftar, [e]);
    id
  };

  public func deposit(escrowId : Nat, amount : Nat) : async () {
    let updated : [Escrow] = Array.tabulate<Escrow>(
      escrowDaftar.size(),
      func(i : Nat) : Escrow {
        let e = escrowDaftar[i];
        if (e.id == escrowId) {
          let baruTotal = e.totalTerkumpul + amount;
          let statusBaru = if (baruTotal >= e.totalTarget) { "TERKUNCI" } else { e.status };
          { id = e.id; permintaanId = e.permintaanId; totalTarget = e.totalTarget; totalTerkumpul = baruTotal; status = statusBaru }
        } else { e }
      }
    );
    escrowDaftar := updated;
  };

  public func confirmBarangDiterima(escrowId : Nat) : async () {
    let updated : [Escrow] = Array.tabulate<Escrow>(
      escrowDaftar.size(),
      func(i : Nat) : Escrow {
        let e = escrowDaftar[i];
        if (e.id == escrowId) {
          { id = e.id; permintaanId = e.permintaanId; totalTarget = e.totalTarget; totalTerkumpul = e.totalTerkumpul; status = "DILEPASKAN" }
        } else { e }
      }
    );
    escrowDaftar := updated;
  };

  // ===== JSON helpers =====
  func joinWithComma(arr : [Text]) : Text {
    var result : Text = "";
    var first : Bool = true;
    for (t in Iter.fromArray(arr)) {
      if (first) { result := t; first := false } else { result := result # "," # t };
    };
    result
  };

  func jsonEscape(t : Text) : Text { t }; // naive for MVP

  func permintaanToJSON(p : Permintaan) : Text {
    "{" #
    "\"id\":" # Nat.toText(p.id) # "," #
    "\"namaBarang\":\"" # jsonEscape(p.namaBarang) # "\"," #
    "\"totalKuantitas\":" # Nat.toText(p.totalKuantitas) # "," #
    "\"unit\":\"" # jsonEscape(p.unit) # "\"," #
    "\"jumlahPartisipan\":" # Nat.toText(p.jumlahPartisipan) # "," #
    "\"status\":\"" # jsonEscape(p.status) # "\"" #
    "}"
  };

  func umkmToJSON(u : Umkm) : Text {
    "{" #
    "\"id\":" # Nat.toText(u.id) # "," #
    "\"namaUsaha\":\"" # jsonEscape(u.namaUsaha) # "\"," #
    "\"lokasi\":\"" # jsonEscape(u.lokasi) # "\"" #
    "}"
  };

  func kebutuhanToJSON(k : Kebutuhan) : Text {
    "{" #
    "\"id\":" # Nat.toText(k.id) # "," #
    "\"umkmId\":" # Nat.toText(k.umkmId) # "," #
    "\"namaBarang\":\"" # jsonEscape(k.namaBarang) # "\"," #
    "\"kuantitas\":" # Nat.toText(k.kuantitas) # "," #
    "\"unit\":\"" # jsonEscape(k.unit) # "\"," #
    "\"lokasi\":\"" # jsonEscape(k.lokasi) # "\"," #
    "\"status\":\"" # jsonEscape(k.status) # "\"" #
    "}"
  };

  func notifToJSON(n : Notifikasi) : Text {
    "{" #
    "\"id\":" # Nat.toText(n.id) # "," #
    "\"pesan\":\"" # jsonEscape(n.pesan) # "\"" #
    "}"
  };

  func escrowToJSON(e : Escrow) : Text {
    "{" #
    "\"id\":" # Nat.toText(e.id) # "," #
    "\"permintaanId\":" # Nat.toText(e.permintaanId) # "," #
    "\"totalTarget\":" # Nat.toText(e.totalTarget) # "," #
    "\"totalTerkumpul\":" # Nat.toText(e.totalTerkumpul) # "," #
    "\"status\":\"" # jsonEscape(e.status) # "\"" #
    "}"
  };

  // ===== HTTP Query Endpoint (Read-only JSON) =====
  public query func http_request(req : Http.Request) : async Http.Response {
    let url : Text = req.url;
    let (status, contentType, bodyText) =
      if (Text.contains(url, #text "permintaan")) {
        let itemsText : [Text] = Array.map<Permintaan, Text>(permintaanDaftar, permintaanToJSON);
        (200, "application/json", "[" # joinWithComma(itemsText) # "]")
      } else if (Text.contains(url, #text "umkm")) {
        let itemsText : [Text] = Array.map<Umkm, Text>(umkmDaftar, umkmToJSON);
        (200, "application/json", "[" # joinWithComma(itemsText) # "]")
      } else if (Text.contains(url, #text "kebutuhan")) {
        let itemsText : [Text] = Array.map<Kebutuhan, Text>(kebutuhanDaftar, kebutuhanToJSON);
        (200, "application/json", "[" # joinWithComma(itemsText) # "]")
      } else if (Text.contains(url, #text "notifikasi")) {
        let itemsText : [Text] = Array.map<Notifikasi, Text>(notifikasiDaftar, notifToJSON);
        (200, "application/json", "[" # joinWithComma(itemsText) # "]")
      } else if (Text.contains(url, #text "escrow")) {
        let itemsText : [Text] = Array.map<Escrow, Text>(escrowDaftar, escrowToJSON);
        (200, "application/json", "[" # joinWithComma(itemsText) # "]")
      } else {
        (200, "text/plain", "Kawan UMKM Backend aktif")
      };

    {
      status_code = Nat16.fromNat(status);
      headers = [ ("Content-Type", contentType), ("Access-Control-Allow-Origin", "*") ];
      body = Text.encodeUtf8(bodyText);
      streaming_strategy = null;
    }
  };
}