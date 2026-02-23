import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/dark_theme.dart';

class PhotoPickerWidget extends StatelessWidget {
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

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 1920, imageQuality: 85);
    onChanged(file);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
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
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.gallery);
              },
            ),
            if (pickedFile != null || existingUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.error),
                title: const Text('Hapus Foto', style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  onChanged(null);
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
        Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showOptions(context),
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
    if (pickedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(pickedFile!.path),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    if (existingUrl != null && existingUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: existingUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppTheme.textSecondary),
        ),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, color: AppTheme.textSecondary, size: 28),
        SizedBox(height: 4),
        Text('Tap untuk upload', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}
