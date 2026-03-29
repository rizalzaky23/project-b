import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../core/theme/dark_theme.dart';

enum PdfStatus { unchanged, picked, deleted }

class PdfResult {
  final XFile? file;
  final PdfStatus status;
  const PdfResult({required this.file, required this.status});
  bool get isDeleted => status == PdfStatus.deleted;
  bool get hasPicked => status == PdfStatus.picked && file != null;
}

class PdfPickerWidget extends StatefulWidget {
  final String label;
  final XFile? pickedFile;
  final String? existingUrl;
  final void Function(PdfResult)? onPdfResult;

  const PdfPickerWidget({
    super.key,
    required this.label,
    this.pickedFile,
    this.existingUrl,
    this.onPdfResult,
  });

  @override
  State<PdfPickerWidget> createState() => _PdfPickerWidgetState();
}

class _PdfPickerWidgetState extends State<PdfPickerWidget> {
  XFile? _pickedFile;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _pickedFile = widget.pickedFile;
  }

  @override
  void didUpdateWidget(covariant PdfPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickedFile != oldWidget.pickedFile) {
      _pickedFile = widget.pickedFile;
    }
  }

  Future<void> _pick() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        mimeTypes: ['application/pdf'],
        uniformTypeIdentifiers: ['com.adobe.pdf'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        setState(() {
          _pickedFile = file;
          _isDeleted = false;
        });
        widget.onPdfResult
            ?.call(PdfResult(file: file, status: PdfStatus.picked));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _delete() {
    setState(() {
      _pickedFile = null;
      _isDeleted = true;
    });
    widget.onPdfResult
        ?.call(const PdfResult(file: null, status: PdfStatus.deleted));
  }

  bool get _hasFile =>
      _pickedFile != null ||
      (widget.existingUrl != null &&
          widget.existingUrl!.isNotEmpty &&
          !_isDeleted);

  String? get _fileName {
    if (_pickedFile != null) return _pickedFile!.name;
    if (widget.existingUrl != null &&
        widget.existingUrl!.isNotEmpty &&
        !_isDeleted) {
      final uri = Uri.tryParse(widget.existingUrl!);
      return uri?.pathSegments.isNotEmpty == true
          ? uri!.pathSegments.last
          : 'dokumen.pdf';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isDeleted
                    ? AppTheme.error.withOpacity(0.4)
                    : _hasFile
                        ? AppTheme.primary.withOpacity(0.4)
                        : AppTheme.divider,
              ),
            ),
            child: _isDeleted
                ? _buildDeleted()
                : _hasFile
                    ? _buildHasFile()
                    : _buildEmpty(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.upload_file_outlined,
            color: AppTheme.primary, size: 20),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Upload PDF',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text('Tap untuk pilih file PDF',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ),
      const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
    ]);
  }

  Widget _buildHasFile() {
    final isNew = _pickedFile != null;
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C).withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.picture_as_pdf_rounded,
            color: Color(0xFFE74C3C), size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          isNew ? 'File Baru Dipilih' : 'File Tersimpan',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          _fileName ?? '',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ])),
      IconButton(
        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
        color: AppTheme.primary,
        onPressed: _pick,
        tooltip: 'Ganti PDF',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
        tooltip: 'Hapus PDF',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: _delete,
      ),
    ]);
  }

  Widget _buildDeleted() {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.hide_source_outlined,
            color: AppTheme.error, size: 20),
      ),
      const SizedBox(width: 12),
      const Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('File Dihapus',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
                fontSize: 13)),
        Text('Tap untuk pilih file baru',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ])),
    ]);
  }
}
