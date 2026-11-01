// Tugas Rutin 4: Sistem Parkir Rumah Sakit
// Nama: Nayla Luthfiah Hanan  NIM: 4243250054
import 'dart:async';

// ======================= MODEL KENDARAAN =======================

/// Kelas dasar semua kendaraan di area parkir.
abstract class Kendaraan {
  final String plat;

  /// Waktu masuk dicatat otomatis saat objek dibuat.
  final DateTime waktuMasuk = DateTime.now();

  Kendaraan(this.plat);

  String get jenis;
  int get tarifPerJam;
  String get namaTampil => jenis;

  /// Biaya parkir: dibulatkan ke atas per jam, minimal 1 jam.
  int biaya(DateTime keluar) {
    final detik = keluar.difference(waktuMasuk).inSeconds;
    final jam = (detik / 3600).ceil();
    return tarifPerJam * (jam < 1 ? 1 : jam);
  }
}

class Motor extends Kendaraan {
  Motor(super.plat);

  @override
  String get jenis => 'Motor';

  @override
  int get tarifPerJam => 2000;
}

class Mobil extends Kendaraan {
  Mobil(super.plat);

  @override
  String get jenis => 'Mobil';

  @override
  int get tarifPerJam => 4000;
}

/// Ambulans gratis: biaya() ditimpa menjadi 0.
class Ambulans extends Kendaraan {
  Ambulans(super.plat);

  @override
  String get jenis => 'Ambulans';

  @override
  int get tarifPerJam => 0;

  @override
  int biaya(DateTime keluar) => 0;
}

/// Mixin diskon untuk kendaraan berlangganan (member).
mixin DiskonMember on Kendaraan {
  int get persenDiskon => 25;

  @override
  String get namaTampil => '${super.namaTampil} (member)';

  @override
  int biaya(DateTime keluar) =>
      super.biaya(keluar) * (100 - persenDiskon) ~/ 100;
}

class MobilMember extends Mobil with DiskonMember {
  MobilMember(super.plat);
}

// ================= PERISTIWA UNTUK LAYAR POS (SEALED) =================
sealed class Peristiwa {}

class Masuk extends Peristiwa {
  final Kendaraan kendaraan;
  final int sisa;
  Masuk(this.kendaraan, this.sisa);
}

class Keluar extends Peristiwa {
  final Kendaraan kendaraan;
  final int bayar;
  Keluar(this.kendaraan, this.bayar);
}

class Ditolak extends Peristiwa {
  final String plat;
  final String alasan;
  Ditolak(this.plat, this.alasan);
}

/// switch pada sealed class: compiler memastikan semua subtipe ditangani.
String tampil(Peristiwa p) => switch (p) {
  Masuk(:final kendaraan, :final sisa) =>
    'MASUK   ${kendaraan.namaTampil} ${kendaraan.plat} (sisa $sisa)',
  Keluar(:final kendaraan, :final bayar) =>
    'KELUAR  ${kendaraan.namaTampil} ${kendaraan.plat} bayar Rp$bayar',
  Ditolak(:final plat, :final alasan) => 'DITOLAK $plat: $alasan',
};

// ======================= EXCEPTION KUSTOM =======================
class ParkirPenuh implements Exception {
  final int kapasitas;
  ParkirPenuh(this.kapasitas);

  @override
  String toString() => 'Parkiran penuh (kapasitas $kapasitas)';
}

class KendaraanTidakAda implements Exception {
  final String plat;
  KendaraanTidakAda(this.plat);

  @override
  String toString() => 'Kendaraan $plat tidak ditemukan';
}

class PlatSudahAda implements Exception {
  final String plat;
  PlatSudahAda(this.plat);

  @override
  String toString() => 'Plat $plat sudah terparkir';
}

// ========================== PARKIRAN ==========================
class Parkiran {
  final int kapasitas;

  // Data privat: hanya bisa diubah lewat method masuk() dan keluar().
  final _aktif = <String, Kendaraan>{};
  int _pendapatan = 0;
  final _peristiwa = StreamController<Peristiwa>.broadcast();

  Parkiran(this.kapasitas);

  int get sisa => kapasitas - _aktif.length;
  int get pendapatan => _pendapatan;
  Stream<Peristiwa> get layarPos => _peristiwa.stream;

  /// Kendaraan masuk. Palang disimulasikan dengan Future.delayed.
  Future<void> masuk(Kendaraan k) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_aktif.containsKey(k.plat)) throw PlatSudahAda(k.plat);
    if (sisa == 0) {
      final galat = ParkirPenuh(kapasitas);
      _peristiwa.add(Ditolak(k.plat, galat.toString()));
      await Future.delayed(Duration.zero); // beri waktu event tampil di layar
      throw galat;
    }
    _aktif[k.plat] = k;
    _peristiwa.add(Masuk(k, sisa));
  }

  /// Kendaraan keluar setelah parkir selama [lama] (disimulasikan).
  Future<int> keluar(String plat, {required Duration lama}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final k = _aktif.remove(plat);
    if (k == null) throw KendaraanTidakAda(plat);
    // Simulasi: waktu keluar = waktu masuk + lama parkir.
    final bayar = k.biaya(k.waktuMasuk.add(lama));
    _pendapatan += bayar;
    _peristiwa.add(Keluar(k, bayar));
    return bayar;
  }

  Future<void> tutup() => _peristiwa.close();
}

// ============================= MAIN =============================
Future<void> main() async {
  final parkir = Parkiran(3);

  // Listener layar pos jaga: menampilkan setiap peristiwa dari Stream.
  parkir.layarPos.map(tampil).listen(print);

  /// Menjalankan aksi async dan menangkap exception tanpa menghentikan program.
  Future<void> coba(Future<void> Function() aksi) async {
    try {
      await aksi();
    } on ParkirPenuh catch (e) {
      print('  -> ParkirPenuh ditangkap di main: $e');
    } on Exception catch (e) {
      print('Gagal: $e');
    }
  }

  // Polimorfisme: satu List<Kendaraan> berisi berbagai jenis kendaraan.
  final antrian = <Kendaraan>[
    Motor('BK 10 RS'),
    Mobil('BK 20 RS'),
    Ambulans('BK 30 RS'),
    MobilMember('BK 40 RS'), // kapasitas 3, jadi ditolak
  ];

  for (final k in antrian) {
    await coba(() => parkir.masuk(k));
  }

  // Method yang sama (biaya) memberi hasil berbeda untuk tiap jenis.
  print('\nSimulasi biaya parkir 2 jam:');
  for (final k in antrian) {
    final bayar = k.biaya(k.waktuMasuk.add(const Duration(hours: 2)));
    print('${k.namaTampil.padRight(18)} Rp$bayar');
  }
  print('');

  // Dua kendaraan keluar bersamaan. 2 jam 20 menit dibulatkan menjadi 3 jam.
  await coba(
    () => Future.wait([
      parkir.keluar('BK 10 RS', lama: const Duration(hours: 2, minutes: 20)),
      parkir.keluar('BK 20 RS', lama: const Duration(hours: 2)),
    ]),
  );
  await coba(() => parkir.keluar('BK 30 RS', lama: const Duration(hours: 5)));
  await coba(() => parkir.keluar('XX 0 XX', lama: const Duration(hours: 1)));

  // Kendaraan baru (objek baru) masuk setelah ada slot kosong.
  await coba(() => parkir.masuk(MobilMember('BK 40 RS')));
  await coba(() => parkir.keluar('BK 40 RS', lama: const Duration(hours: 4)));

  await parkir.tutup();
  print('Pendapatan: Rp${parkir.pendapatan}');
  print('Slot kosong: ${parkir.sisa} dari ${parkir.kapasitas}');
}
