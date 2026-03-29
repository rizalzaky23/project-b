import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/penyewaan_entity.dart';

class PenyewaanModel extends PenyewaanEntity {
  const PenyewaanModel({
    required super.id,
    required super.kendaraanId,
    required super.namaPenyewa,
    required super.group,
    required super.masaSewa,
    required super.tanggalMulai,
    required super.tanggalSelesai,
    required super.penanggungJawab,
    super.lokasiSewa,
    required super.nilaiSewa,
    super.suratPerjanjian,
    super.kendaraan,
  });

  factory PenyewaanModel.fromJson(Map<String, dynamic> j) => PenyewaanModel(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    kendaraanId: int.tryParse(j['kendaraan_id']?.toString() ?? '0') ?? 0,
    namaPenyewa: j['nama_penyewa'] ?? '',
    group: j['group'] == true || j['group'] == 1,
    masaSewa: int.tryParse(j['masa_sewa']?.toString() ?? '0') ?? 0,
    tanggalMulai: j['tanggal_mulai'] ?? '',
    tanggalSelesai: j['tanggal_selesai'] ?? '',
    penanggungJawab: j['penanggung_jawab'] ?? '',
    lokasiSewa: j['lokasi_sewa'],
    nilaiSewa: double.tryParse(j['nilai_sewa']?.toString() ?? '0') ?? 0,
    suratPerjanjian: ApiConstants.photoUrl(j['surat_perjanjian']),
    kendaraan: j['kendaraan'] as Map<String, dynamic>?,
  );
}
