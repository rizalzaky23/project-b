import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/dark_theme.dart';
import 'network_image_widget.dart';

class PhotoPickerWidget extends StatefulWidget {
  final String label;
  final XFile? pickedFile;
  final String? existingUrl;
  final void Function(XFile?) onChanged;

  const PhotoPickerWidget({
    super.key,
    required this.label,
    required this.onChanged,
    this.pickedFile,
    this.existingUrl,
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  Uint8List? _imageBytes;
  XFile? _lastFile;

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
        });
      }
    }
    widget.onChanged(file);
  }

  void _showOptions() {
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
                leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pick(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pick(ImageSource.gallery);
              },
            ),
            if (widget.pickedFile != null || widget.existingUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.error),
                title: const Text('Hapus Foto', style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  setState(() {
                    _imageBytes = null;
                    _lastFile = null;
                  });
                  widget.onChanged(null);
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

    // Gambar dari URL (mode edit)
    if (widget.existingUrl != null && widget.existingUrl!.isNotEmpty) {
      return NetworkImageWidget(
        imageUrl: widget.existingUrl,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(10),
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
