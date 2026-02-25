import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// Helper untuk membuat MultipartFile dari XFile
/// yang kompatibel di Flutter Web maupun Mobile.
/// 
/// `MultipartFile.fromFile()` hanya bekerja di mobile.
/// `MultipartFile.fromBytes()` bekerja di web DAN mobile.
Future<MultipartFile> xFileToMultipart(XFile file) async {
  final bytes = await file.readAsBytes();
  return MultipartFile.fromBytes(
    bytes,
    filename: file.name,
  );
}

/// Helper untuk menambahkan file ke FormData secara aman
Future<void> addFileToForm(FormData formData, String key, XFile? file) async {
  if (file != null) {
    formData.files.add(MapEntry(key, await xFileToMultipart(file)));
  }
}
