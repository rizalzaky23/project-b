import '../../domain/entities/kejadian_entity.dart';
class KejadianModel extends KejadianEntity {
  const KejadianModel({required super.id, required super.kendaraanId, required super.tanggal, super.deskripsi, super.fotoKm, super.foto1, super.foto2, super.kendaraan});
  factory KejadianModel.fromJson(Map<String, dynamic> j) => KejadianModel(id: j['id'], kendaraanId: j['kendaraan_id'], tanggal: j['tanggal'] ?? '', deskripsi: j['deskripsi'], fotoKm: j['foto_km'], foto1: j['foto_1'], foto2: j['foto_2'], kendaraan: j['kendaraan'] as Map<String, dynamic>?);
}
