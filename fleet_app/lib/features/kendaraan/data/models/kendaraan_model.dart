import '../../domain/entities/kendaraan_entity.dart';

class KendaraanModel extends KendaraanEntity {
  const KendaraanModel({
    required super.id,
    required super.kodeKendaraan,
    required super.merk,
    required super.tipe,
    required super.warna,
    required super.noChasis,
    required super.noMesin,
    required super.tahunPerolehan,
    required super.tahunPembuatan,
    required super.hargaPerolehan,
    super.dealer,
    super.fotoDepan,
    super.fotoKiri,
    super.fotoKanan,
    super.fotoBelakang,
    super.createdAt,
  });

  factory KendaraanModel.fromJson(Map<String, dynamic> json) {
    return KendaraanModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kodeKendaraan: json['kode_kendaraan'] ?? '',
      merk: json['merk'] ?? '',
      tipe: json['tipe'] ?? '',
      warna: json['warna'] ?? '',
      noChasis: json['no_chasis'] ?? '',
      noMesin: json['no_mesin'] ?? '',
      tahunPerolehan: int.tryParse(json['tahun_perolehan']?.toString() ?? '0') ?? 0,
      tahunPembuatan: int.tryParse(json['tahun_pembuatan']?.toString() ?? '0') ?? 0,
      hargaPerolehan: double.tryParse(json['harga_perolehan']?.toString() ?? '0') ?? 0,
      dealer: json['dealer'],
      fotoDepan: json['foto_depan'],
      fotoKiri: json['foto_kiri'],
      fotoKanan: json['foto_kanan'],
      fotoBelakang: json['foto_belakang'],
      createdAt: json['created_at'],
    );
  }
}
