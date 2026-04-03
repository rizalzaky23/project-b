import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/kejadian_entity.dart';

class KejadianModel extends KejadianEntity {
  const KejadianModel({
    required super.id, required super.kendaraanId, required super.tanggal,
    super.jenisKejadian, super.kontakPihakKetiga, super.lokasi, super.deskripsi, super.status, super.fotoKm, super.foto1, super.foto2, super.kendaraan,
  });

  factory KejadianModel.fromJson(Map<String, dynamic> j) => KejadianModel(
    id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
    kendaraanId: int.tryParse(j['kendaraan_id']?.toString() ?? '0') ?? 0,
    tanggal: j['tanggal'] ?? '',
    jenisKejadian: j['jenis_kejadian'],
    kontakPihakKetiga: j['kontak_pihak_ketiga'],
    lokasi: j['lokasi'],
    deskripsi: j['deskripsi'],
    status: j['status'],
    fotoKm: ApiConstants.photoUrl(j['foto_km']),
    foto1: ApiConstants.photoUrl(j['foto_1']),
    foto2: ApiConstants.photoUrl(j['foto_2']),
    kendaraan: j['kendaraan'] as Map<String, dynamic>?,
  );
}
