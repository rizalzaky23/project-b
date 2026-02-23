import 'package:equatable/equatable.dart';

class KendaraanEntity extends Equatable {
  final int id;
  final String kodeKendaraan;
  final String merk;
  final String tipe;
  final String warna;
  final String noChasis;
  final String noMesin;
  final int tahunPerolehan;
  final int tahunPembuatan;
  final double hargaPerolehan;
  final String? dealer;
  final String? fotoDepan;
  final String? fotoKiri;
  final String? fotoKanan;
  final String? fotoBelakang;
  final String? createdAt;

  const KendaraanEntity({
    required this.id,
    required this.kodeKendaraan,
    required this.merk,
    required this.tipe,
    required this.warna,
    required this.noChasis,
    required this.noMesin,
    required this.tahunPerolehan,
    required this.tahunPembuatan,
    required this.hargaPerolehan,
    this.dealer,
    this.fotoDepan,
    this.fotoKiri,
    this.fotoKanan,
    this.fotoBelakang,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, kodeKendaraan];
}
