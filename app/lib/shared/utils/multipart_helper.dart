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

/// Helper untuk menambahkan file ke FormData secara aman.
/// Jika [file] tidak null, file akan di-upload.
/// Jika [deleted] true, field [deleteKey] akan dikirim bernilai '1'
/// sehingga server tahu foto tersebut harus dihapus.
Future<void> addFileToForm(
  FormData formData,
  String key,
  XFile? file, {
  bool deleted = false,
  String? deleteKey,
}) async {
  if (file != null) {
    // Upload file baru
    formData.files.add(MapEntry(key, await xFileToMultipart(file)));
  } else if (deleted && deleteKey != null) {
    // Kirim sinyal hapus ke server
    formData.fields.add(MapEntry(deleteKey, '1'));
  }
}
