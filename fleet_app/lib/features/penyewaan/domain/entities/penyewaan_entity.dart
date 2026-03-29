import 'package:equatable/equatable.dart';

class PenyewaanEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String namaPenyewa;
  final bool group;
  final int masaSewa;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String penanggungJawab;
  final String? lokasiSewa;
  final double nilaiSewa;
  final String? suratPerjanjian;
  final Map<String, dynamic>? kendaraan;

  const PenyewaanEntity({
    required this.id, required this.kendaraanId, required this.namaPenyewa,
    required this.group, required this.masaSewa, required this.tanggalMulai,
    required this.tanggalSelesai, required this.penanggungJawab,
    this.lokasiSewa, required this.nilaiSewa, this.suratPerjanjian, this.kendaraan,
  });

  @override List<Object?> get props => [id];
}
