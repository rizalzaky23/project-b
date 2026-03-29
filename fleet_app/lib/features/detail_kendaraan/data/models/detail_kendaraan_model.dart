import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';

class DetailKendaraanModel extends DetailKendaraanEntity {
  const DetailKendaraanModel({
    required super.id, required super.kendaraanId, required super.noPolisi,
    required super.namaPemilik, super.pemilikKomersial, super.pemilikFiskal,
    super.fotoStnk, super.stnkBerlakuMulai, super.stnkBerlakuAkhir,
    super.fotoBpkb, super.fotoNomor, super.fotoKm,
    super.kartuKir, super.lembarKir, super.createdAt, super.kendaraan,
  });

  factory DetailKendaraanModel.fromJson(Map<String, dynamic> json) {
    return DetailKendaraanModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kendaraanId: int.tryParse(json['kendaraan_id']?.toString() ?? '0') ?? 0,
      noPolisi: json['no_polisi'] ?? '',
      namaPemilik: json['nama_pemilik'] ?? '',
      pemilikKomersial: json['pemilik_komersial'],
      pemilikFiskal: json['pemilik_fiskal'],
      fotoStnk: ApiConstants.photoUrl(json['foto_stnk']),
      stnkBerlakuMulai: json['stnk_berlaku_mulai'],
      stnkBerlakuAkhir: json['stnk_berlaku_akhir'],
      fotoBpkb: ApiConstants.photoUrl(json['foto_bpkb']),
      fotoNomor: ApiConstants.photoUrl(json['foto_nomor']),
      fotoKm: ApiConstants.photoUrl(json['foto_km']),
      kartuKir: ApiConstants.photoUrl(json['kartu_kir']),
      lembarKir: ApiConstants.photoUrl(json['lembar_kir']),
      createdAt: json['created_at'],
      kendaraan: json['kendaraan'] as Map<String, dynamic>?,
    );
  }
}
