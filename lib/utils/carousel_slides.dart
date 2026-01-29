import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CarouselSection extends StatefulWidget {
  final List<String> imagePaths;
  const CarouselSection({super.key, required this.imagePaths});

  @override
  State<CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<CarouselSection> {
  final List<double> _aspectRatios = [];

  @override
  void initState() {
    super.initState();
    _loadAspectRatios();
  }

  Future<void> _loadAspectRatios() async {
    final List<double> ratios = [];
    double tallestHeight = 0;
    final screenWidth = WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio;

    for (final path in widget.imagePaths) {
      try {
        final completer = Completer<ui.Image>();
        final imageProvider = CachedNetworkImageProvider(path);
        imageProvider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((info, _) => completer.complete(info.image)),
        );
        final img = await completer.future;

        final ratio = img.width / img.height;
        ratios.add(ratio);

        final estHeight = screenWidth / ratio;
        if (estHeight > tallestHeight) tallestHeight = estHeight;
      } catch (_) {
        ratios.add(1.0);
      }
    }

    if (mounted) {
      setState(() {
        _aspectRatios
          ..clear()
          ..addAll(ratios);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final double effectiveHeight = MediaQuery.of(context).size.height * 0.6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: effectiveHeight,
          width: screenWidth,
          child: CarouselSlider.builder(
            itemCount: widget.imagePaths.length,
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              height: MediaQuery.of(context).size.height * (MediaQuery.of(context).size.width > 1000 ? 0.55 : 0.65)),
              itemBuilder: (context, index, realIndex) {
                final path = widget.imagePaths[index];
                return GestureDetector(
                  onTap: () => _showZoomableGallery(context, widget.imagePaths, index),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CachedNetworkImage(
                          imageUrl: path,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60),
                        );
                      },
                    ),
                  ),
                );
              }
            )
          );
        },
      );
    }

  void _showZoomableGallery(BuildContext context, List<String> imagePaths, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Close zoom view',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => Center(
        child: ZoomableImageGallery(
          imagePaths: imagePaths,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class ZoomableImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ZoomableImageGallery({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<ZoomableImageGallery> createState() => _ZoomableImageGalleryState();
}

class _ZoomableImageGalleryState extends State<ZoomableImageGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoViewGallery.builder(
          pageController: _pageController,
          itemCount: widget.imagePaths.length,
          builder: (context, index) {
            final imageUrl = widget.imagePaths[index];
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.5,
            );
          },
          loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          top: 30,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}