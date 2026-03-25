import 'package:equatable/equatable.dart';

class PenyewaanEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String kodePenyewa;
  final bool group;
  final int masaSewa;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String penanggungJawab;
  final String? lokasiSewa;
  final String? sales;
  final double nilaiSewa;
  final Map<String, dynamic>? kendaraan;

  const PenyewaanEntity({
    required this.id, required this.kendaraanId, required this.kodePenyewa,
    required this.group, required this.masaSewa, required this.tanggalMulai,
    required this.tanggalSelesai, required this.penanggungJawab,
    this.lokasiSewa, this.sales, required this.nilaiSewa, this.kendaraan,
  });

  @override List<Object?> get props => [id];
}
