import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// Membuat MultipartFile dari XFile (gambar).
/// Kompatibel di Flutter Web dan Mobile.
Future<MultipartFile> xFileToMultipart(XFile file) async {
  final bytes = await file.readAsBytes();
  return MultipartFile.fromBytes(bytes, filename: file.name);
}

/// Membuat MultipartFile dari XFile PDF dengan content-type eksplisit.
/// Diperlukan agar server Laravel dapat memvalidasi mimes:pdf.
Future<MultipartFile> xFileToPdfMultipart(XFile file) async {
  final bytes = await file.readAsBytes();
  return MultipartFile.fromBytes(
    bytes,
    filename: file.name,
    contentType: DioMediaType('application', 'pdf'),
  );
}

/// Menambahkan XFile gambar ke FormData secara aman.
Future<void> addFileToForm(
  FormData formData,
  String key,
  XFile? file, {
  bool deleted = false,
  String? deleteKey,
}) async {
  if (file != null) {
    formData.files.add(MapEntry(key, await xFileToMultipart(file)));
  } else if (deleted && deleteKey != null) {
    formData.fields.add(MapEntry(deleteKey, '1'));
  }
}

/// Menambahkan XFile PDF ke FormData dengan content-type application/pdf.
/// Gunakan ini untuk file kontrak agar server dapat memvalidasinya dengan benar.
Future<void> addPdfToForm(
  FormData formData,
  String key,
  XFile? file, {
  bool deleted = false,
  String? deleteKey,
}) async {
  if (file != null) {
    formData.files.add(MapEntry(key, await xFileToPdfMultipart(file)));
  } else if (deleted && deleteKey != null) {
    formData.fields.add(MapEntry(deleteKey, '1'));
  }
}
