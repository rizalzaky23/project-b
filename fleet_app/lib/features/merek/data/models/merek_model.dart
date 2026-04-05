import '../../domain/entities/merek_entity.dart';

class MerekModel extends MerekEntity {
  const MerekModel({required super.id, required super.nama});

  factory MerekModel.fromJson(Map<String, dynamic> json) {
    return MerekModel(id: json['id'], nama: json['nama']);
  }
}
