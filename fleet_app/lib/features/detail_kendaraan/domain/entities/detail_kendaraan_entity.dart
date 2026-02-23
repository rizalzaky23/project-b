import 'package:equatable/equatable.dart';

class DetailKendaraanEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String noPolisi;
  final String? berlakuMulai;
  final String namaPemilik;
  final String? fotoStnk;
  final String? fotoBpkb;
  final String? fotoNomor;
  final String? fotoKm;
  final String? createdAt;
  final Map<String, dynamic>? kendaraan;

  const DetailKendaraanEntity({
    required this.id,
    required this.kendaraanId,
    required this.noPolisi,
    this.berlakuMulai,
    required this.namaPemilik,
    this.fotoStnk,
    this.fotoBpkb,
    this.fotoNomor,
    this.fotoKm,
    this.createdAt,
    this.kendaraan,
  });

  @override
  List<Object?> get props => [id];
}
