import 'package:equatable/equatable.dart';

class AsuransiEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String perusahaanAsuransi;
  final String jenisAsuransi;
  final String tanggalMulai;
  final String tanggalAkhir;
  final String noPolis;
  final double nilaiPremi;
  final double nilaiPertanggungan;
  final String? fotoDepan, fotoKiri, fotoKanan, fotoBelakang, fotoDashboard;
  final String? updatedAt;
  final Map<String, dynamic>? kendaraan;

  const AsuransiEntity({
    required this.id,
    required this.kendaraanId,
    required this.perusahaanAsuransi,
    required this.jenisAsuransi,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    required this.noPolis,
    required this.nilaiPremi,
    required this.nilaiPertanggungan,
    this.fotoDepan, this.fotoKiri, this.fotoKanan, this.fotoBelakang, this.fotoDashboard,
    this.updatedAt,
    this.kendaraan,
  });

  @override
  List<Object?> get props => [id];
}
