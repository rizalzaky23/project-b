import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'network_image_widget.dart';

/// Widget foto yang bisa ditekan untuk membuka popup fullscreen.
class TappablePhoto extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final List<String?>? allPhotos; // untuk swipe antar foto
  final int initialIndex;

  const TappablePhoto({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.allPhotos,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final photos = allPhotos?.where((p) => p != null && p.isNotEmpty).cast<String>().toList()
            ?? (imageUrl != null && imageUrl!.isNotEmpty ? [imageUrl!] : []);
        if (photos.isEmpty) return;
        showPhotoViewer(context, photos: photos, initialIndex: initialIndex);
      },
      child: NetworkImageWidget(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Membuka fullscreen photo viewer dengan swipe support.
void showPhotoViewer(BuildContext context, {required List<String> photos, int initialIndex = 0}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, __, ___) => _PhotoViewerPage(photos: photos, initialIndex: initialIndex),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _PhotoViewerPage extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  const _PhotoViewerPage({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Foto swipeable
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, i) => _ZoomablePhoto(url: widget.photos[i]),
          ),

          // Tombol tutup
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Indikator halaman (jika lebih dari 1 foto)
          if (widget.photos.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.photos.length, (i) {
                  final isActive = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // Counter (misal 2/4)
          if (widget.photos.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photos.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomablePhoto extends StatefulWidget {
  final String url;
  const _ZoomablePhoto({required this.url});

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto> {
  final _transformController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    } else if (_doubleTapDetails != null) {
      final pos = _doubleTapDetails!.localPosition;
      _transformController.value = Matrix4.identity()
        ..translate(-pos.dx * 2, -pos.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.5,
        maxScale: 5.0,
        child: Center(
          child: NetworkImageWidget(
            imageUrl: widget.url,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
