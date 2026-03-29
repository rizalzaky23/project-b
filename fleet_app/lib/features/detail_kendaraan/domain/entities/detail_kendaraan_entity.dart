import 'package:equatable/equatable.dart';

class DetailKendaraanEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String noPolisi;
  final String namaPemilik;
  final String? pemilikKomersial;
  final String? pemilikFiskal;
  final String? fotoStnk;
  final String? stnkBerlakuMulai;
  final String? stnkBerlakuAkhir;
  final String? fotoBpkb;
  final String? fotoNomor;
  final String? fotoKm;
  final String? kartuKir;
  final String? lembarKir;
  final String? createdAt;
  final Map<String, dynamic>? kendaraan;

  const DetailKendaraanEntity({
    required this.id,
    required this.kendaraanId,
    required this.noPolisi,
    required this.namaPemilik,
    this.pemilikKomersial,
    this.pemilikFiskal,
    this.fotoStnk,
    this.stnkBerlakuMulai,
    this.stnkBerlakuAkhir,
    this.fotoBpkb,
    this.fotoNomor,
    this.fotoKm,
    this.kartuKir,
    this.lembarKir,
    this.createdAt,
    this.kendaraan,
  });

  @override
  List<Object?> get props => [id];
}
