import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/dark_theme.dart';
import 'network_image_widget.dart';

/// Status foto untuk membedakan antara:
/// - [PhotoStatus.unchanged]  : tidak ada perubahan (pakai foto lama)
/// - [PhotoStatus.picked]     : ada foto baru yang dipilih user
/// - [PhotoStatus.deleted]    : user menghapus foto yang sudah ada
enum PhotoStatus { unchanged, picked, deleted }

/// Hasil callback dari [PhotoPickerWidget].
class PhotoResult {
  final XFile? file;
  final PhotoStatus status;

  const PhotoResult({required this.file, required this.status});

  /// Helper: apakah foto ini dihapus (perlu dikirim sinyal hapus ke API)?
  bool get isDeleted => status == PhotoStatus.deleted;

  /// Helper: apakah ada file baru untuk diupload?
  bool get hasPicked => status == PhotoStatus.picked && file != null;
}

class PhotoPickerWidget extends StatefulWidget {
  final String label;
  final XFile? pickedFile;
  final String? existingUrl;

  /// Callback lama (opsional, untuk kompatibilitas)
  final void Function(XFile?)? onChanged;

  /// Callback baru dengan info status hapus/ganti
  final void Function(PhotoResult)? onPhotoResult;

  const PhotoPickerWidget({
    super.key,
    required this.label,
    this.onChanged,
    this.onPhotoResult,
    this.pickedFile,
    this.existingUrl,
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  Uint8List? _imageBytes;
  XFile? _lastFile;

  /// Apakah user sudah menghapus foto yang ada (existingUrl)?
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _loadBytesIfNeeded();
  }

  @override
  void didUpdateWidget(covariant PhotoPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickedFile?.path != _lastFile?.path) {
      _loadBytesIfNeeded();
    }
  }

  Future<void> _loadBytesIfNeeded() async {
    if (widget.pickedFile != null) {
      final bytes = await widget.pickedFile!.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _lastFile = widget.pickedFile;
          _isDeleted = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _imageBytes = null;
          _lastFile = null;
        });
      }
    }
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _lastFile = file;
          _isDeleted = false;
        });
      }
      final result = PhotoResult(file: file, status: PhotoStatus.picked);
      widget.onPhotoResult?.call(result);
      widget.onChanged?.call(file);
    }
  }

  void _delete() {
    setState(() {
      _imageBytes = null;
      _lastFile = null;
      _isDeleted = true;
    });
    const result = PhotoResult(file: null, status: PhotoStatus.deleted);
    widget.onPhotoResult?.call(result);
    widget.onChanged?.call(null);
  }

  void _showOptions() {
    final hasPhoto = _imageBytes != null ||
        (widget.existingUrl != null &&
            widget.existingUrl!.isNotEmpty &&
            !_isDeleted);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppTheme.primary),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pick(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppTheme.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pick(ImageSource.gallery);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.error),
                title: const Text('Hapus Foto',
                    style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _delete();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _showOptions,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.divider),
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Preview dari bytes — works di web DAN mobile
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    // Gambar dari URL (mode edit) — tampilkan hanya jika belum dihapus
    if (widget.existingUrl != null &&
        widget.existingUrl!.isNotEmpty &&
        !_isDeleted) {
      return Stack(
        fit: StackFit.expand,
        children: [
          NetworkImageWidget(
            imageUrl: widget.existingUrl,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      );
    }

    // Placeholder: dihapus
    if (_isDeleted) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hide_image_outlined, color: AppTheme.error, size: 28),
          SizedBox(height: 4),
          Text('Foto dihapus',
              style: TextStyle(color: AppTheme.error, fontSize: 12)),
        ],
      );
    }

    // Placeholder kosong
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            color: AppTheme.textSecondary, size: 28),
        SizedBox(height: 4),
        Text('Tap untuk upload',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}
