import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/kendaraan_entity.dart';

class KendaraanModel extends KendaraanEntity {
  const KendaraanModel({
    required super.id, required super.kodeKendaraan, required super.merk,
    required super.tipe, required super.warna, required super.noChasis,
    required super.noMesin, required super.tahunPerolehan, required super.tahunPembuatan,
    required super.hargaPerolehan, super.dealer, super.kepemilikan,
    super.jenisPembayaran, super.jenisKredit, super.tenor, super.fileKontrak,
    super.fotoDepan, super.fotoKiri, super.fotoKanan, super.fotoBelakang,
    super.status, super.tanggalJual, super.hargaJual, super.createdAt,
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
      kepemilikan: json['kepemilikan'],
      jenisPembayaran: json['jenis_pembayaran'],
      jenisKredit: json['jenis_kredit'],
      tenor: json['tenor'] != null ? int.tryParse(json['tenor'].toString()) : null,
      fileKontrak: json['file_kontrak'] != null
          ? ApiConstants.photoUrl(json['file_kontrak'])
          : null,
      fotoDepan: ApiConstants.photoUrl(json['foto_depan']),
      fotoKiri: ApiConstants.photoUrl(json['foto_kiri']),
      fotoKanan: ApiConstants.photoUrl(json['foto_kanan']),
      fotoBelakang: ApiConstants.photoUrl(json['foto_belakang']),
      status: json['status'] ?? 'Tersedia',
      tanggalJual: json['tanggal_jual'],
      hargaJual: json['harga_jual'] != null ? double.tryParse(json['harga_jual'].toString()) : null,
      createdAt: json['created_at'],
    );
  }
}
