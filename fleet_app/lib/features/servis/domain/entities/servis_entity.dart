import 'package:equatable/equatable.dart';

class ServisEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String tanggalServis;
  final int kilometer;
  final String? fotoKm;
  final String? fotoInvoice;
  final String? jenisPembayaran;
  final String? jenisKredit;
  final String? namaBank;
  final int? tenor;
  final String? fileKontrak;
  final Map<String, dynamic>? kendaraan;

  const ServisEntity({
    required this.id,
    required this.kendaraanId,
    required this.tanggalServis,
    required this.kilometer,
    this.fotoKm,
    this.fotoInvoice,
    this.jenisPembayaran,
    this.jenisKredit,
    this.namaBank,
    this.tenor,
    this.fileKontrak,
    this.kendaraan,
  });

  @override
  List<Object?> get props => [id];
}
