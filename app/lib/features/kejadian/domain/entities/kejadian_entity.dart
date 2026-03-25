import 'package:equatable/equatable.dart';

class KejadianEntity extends Equatable {
  final int id;
  final int kendaraanId;
  final String tanggal;
  final String? deskripsi;
  final String? fotoKm, foto1, foto2;
  final Map<String, dynamic>? kendaraan;

  const KejadianEntity({required this.id, required this.kendaraanId, required this.tanggal, this.deskripsi, this.fotoKm, this.foto1, this.foto2, this.kendaraan});

  @override
  List<Object?> get props => [id];
}
