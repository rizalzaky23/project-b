import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/asuransi_entity.dart';

class AsuransiModel extends AsuransiEntity {
  const AsuransiModel({
    required super.id,
    required super.kendaraanId,
    required super.perusahaanAsuransi,
    required super.jenisAsuransi,
    required super.tanggalMulai,
    required super.tanggalAkhir,
    required super.noPolis,
    required super.nilaiPremi,
    required super.nilaiPertanggungan,
    super.fotoDepan,
    super.fotoKiri,
    super.fotoKanan,
    super.fotoBelakang,
    super.fotoDashboard,
    super.fotoKm,
    super.kendaraan,
  });

  factory AsuransiModel.fromJson(Map<String, dynamic> j) => AsuransiModel(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    kendaraanId: int.tryParse(j['kendaraan_id']?.toString() ?? '0') ?? 0,
    perusahaanAsuransi: j['perusahaan_asuransi'] ?? '',
    jenisAsuransi: j['jenis_asuransi'] ?? '',
    tanggalMulai: j['tanggal_mulai'] ?? '',
    tanggalAkhir: j['tanggal_akhir'] ?? '',
    noPolis: j['no_polis'] ?? '',
    nilaiPremi: double.tryParse(j['nilai_premi']?.toString() ?? '0') ?? 0,
    nilaiPertanggungan: double.tryParse(j['nilai_pertanggungan']?.toString() ?? '0') ?? 0,
    fotoDepan: ApiConstants.resolveFileUrl(j['foto_depan']),
    fotoKiri: ApiConstants.resolveFileUrl(j['foto_kiri']),
    fotoKanan: ApiConstants.resolveFileUrl(j['foto_kanan']),
    fotoBelakang: ApiConstants.resolveFileUrl(j['foto_belakang']),
    fotoDashboard: ApiConstants.resolveFileUrl(j['foto_dashboard']),
    fotoKm: ApiConstants.resolveFileUrl(j['foto_km']),
    kendaraan: j['kendaraan'] as Map<String, dynamic>?,
  );
}
