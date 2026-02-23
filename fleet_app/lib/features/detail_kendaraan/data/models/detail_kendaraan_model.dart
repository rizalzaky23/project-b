import '../../domain/entities/detail_kendaraan_entity.dart';

class DetailKendaraanModel extends DetailKendaraanEntity {
  const DetailKendaraanModel({
    required super.id,
    required super.kendaraanId,
    required super.noPolisi,
    super.berlakuMulai,
    required super.namaPemilik,
    super.fotoStnk,
    super.fotoBpkb,
    super.fotoNomor,
    super.fotoKm,
    super.createdAt,
    super.kendaraan,
  });

  factory DetailKendaraanModel.fromJson(Map<String, dynamic> json) {
    return DetailKendaraanModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kendaraanId: int.tryParse(json['kendaraan_id']?.toString() ?? '0') ?? 0,
      noPolisi: json['no_polisi'] ?? '',
      berlakuMulai: json['berlaku_mulai'],
      namaPemilik: json['nama_pemilik'] ?? '',
      fotoStnk: json['foto_stnk'],
      fotoBpkb: json['foto_bpkb'],
      fotoNomor: json['foto_nomor'],
      fotoKm: json['foto_km'],
      createdAt: json['created_at'],
      kendaraan: json['kendaraan'] as Map<String, dynamic>?,
    );
  }
}
