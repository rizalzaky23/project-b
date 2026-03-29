import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/servis_entity.dart';

class ServisModel extends ServisEntity {
  const ServisModel({
    required super.id,
    required super.kendaraanId,
    required super.tanggalServis,
    required super.kilometer,
    super.fotoKm,
    super.fotoInvoice,
    super.jenisPembayaran,
    super.jenisKredit,
    super.namaBank,
    super.tenor,
    super.fileKontrak,
    super.kendaraan,
  });

  factory ServisModel.fromJson(Map<String, dynamic> j) => ServisModel(
        id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
        kendaraanId: int.tryParse(j['kendaraan_id']?.toString() ?? '0') ?? 0,
        tanggalServis: j['tanggal_servis'] ?? '',
        kilometer: int.tryParse(j['kilometer']?.toString() ?? '0') ?? 0,
        fotoKm: ApiConstants.photoUrl(j['foto_km']),
        fotoInvoice: ApiConstants.photoUrl(j['foto_invoice']),
        jenisPembayaran: j['jenis_pembayaran']?.toString(),
        jenisKredit: j['jenis_kredit']?.toString(),
        namaBank: j['nama_bank']?.toString(),
        tenor: j['tenor'] != null ? int.tryParse(j['tenor'].toString()) : null,
        fileKontrak: ApiConstants.photoUrl(j['file_kontrak']),
        kendaraan: j['kendaraan'] as Map<String, dynamic>?,
      );
}
