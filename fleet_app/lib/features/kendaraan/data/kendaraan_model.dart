class Kendaraan {
  final int id;
  final String merk;
  final String model;
  final String nomorPolisi;
  final List<String> photos;

  Kendaraan({required this.id, required this.merk, required this.model, required this.nomorPolisi, required this.photos});

  factory Kendaraan.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null) {
      throw ArgumentError('ID is required');
    }
    final idInt = id is int ? id : int.tryParse(id.toString());
    if (idInt == null) {
      throw ArgumentError('ID must be a valid integer');
    }
    
    final photosList = json['photos'];
    List<String> photos = [];
    if (photosList is List<dynamic>) {
      photos = photosList.whereType<String>().toList();
    }
    
    return Kendaraan(
      id: idInt,
      merk: (json['merk'] ?? '') as String,
      model: (json['model'] ?? '') as String,
      nomorPolisi: (json['nomor_polisi'] ?? '') as String,
      photos: photos,
    );
  }
}
