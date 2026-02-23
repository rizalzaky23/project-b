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
    fotoDepan: j['foto_depan'],
    fotoKiri: j['foto_kiri'],
    fotoKanan: j['foto_kanan'],
    fotoBelakang: j['foto_belakang'],
    fotoDashboard: j['foto_dashboard'],
    fotoKm: j['foto_km'],
    kendaraan: j['kendaraan'] as Map<String, dynamic>?,
  );
}
