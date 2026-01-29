import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui' as ui;

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}

class ResponsiveImage extends StatefulWidget {
  final String imagePath;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const ResponsiveImage({
    super.key,
    required this.imagePath,
    this.padding = const EdgeInsets.all(20.0),
    this.maxWidth = 400,
  });

  @override
  State<ResponsiveImage> createState() => _ResponsiveImageState();
}

class _ResponsiveImageState extends State<ResponsiveImage> {
  double? _aspectRatio;

  bool get isNetworkImage => widget.imagePath.startsWith('http');

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatio();
  }

  Future<void> _loadImageAspectRatio() async {
    try {
      ui.Image image;
      if (isNetworkImage) {
        final completer = Completer<ui.Image>();
        final networkImage = NetworkImage(widget.imagePath);
        networkImage.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((info, _) {
            completer.complete(info.image);
          }),
        );
        image = await completer.future;
      } else {
        final data = await rootBundle.load(widget.imagePath);
        final completer = Completer<ui.Image>();
        ui.decodeImageFromList(data.buffer.asUint8List(), (img) {
          completer.complete(img);
        });
        image = await completer.future;
      }

      if (mounted) {
        setState(() {
          _aspectRatio = image.width / image.height;
        });
      }
    } catch (e) {
      debugPrint("Error loading aspect ratio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: widget.padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth < widget.maxWidth
                ? screenWidth * 0.95
                : widget.maxWidth,
          ),
          child: _aspectRatio == null
              ? const Center(child: CircularProgressIndicator())
              : AspectRatio(
                  aspectRatio: _aspectRatio!,
                  child: isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: widget.imagePath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.red, size: 60),
                        )
                      : Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red, size: 60),
                        ),
                ),
        ),
      ),
    );
  }
}

class ResponsiveZoomableImage extends StatefulWidget {
  final String imagePath;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const ResponsiveZoomableImage({
    super.key,
    required this.imagePath,
    this.padding = const EdgeInsets.symmetric(vertical: 20.0),
    this.maxWidth = 600,
  });

  @override
  State<ResponsiveZoomableImage> createState() => _ResponsiveZoomableImageState();
}

class _ResponsiveZoomableImageState extends State<ResponsiveZoomableImage> {
  double? _aspectRatio;
  bool get isNetworkImage => widget.imagePath.startsWith('http');

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatio();
  }

  Future<void> _loadImageAspectRatio() async {
    try {
      ui.Image image;
      if (isNetworkImage) {
        final completer = Completer<ui.Image>();
        final networkImage = NetworkImage(widget.imagePath);
        networkImage.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((info, _) => completer.complete(info.image)),
        );
        image = await completer.future;
      } else {
        final data = await rootBundle.load(widget.imagePath);
        final completer = Completer<ui.Image>();
        ui.decodeImageFromList(data.buffer.asUint8List(),
            (img) => completer.complete(img));
        image = await completer.future;
      }

      if (mounted) {
        setState(() {
          _aspectRatio = image.width / image.height;
        });
      }
    } catch (e) {
      debugPrint("Error loading image aspect ratio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final safeWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : screenWidth;

          return Center(
            child: GestureDetector(
              onTap: () => _showZoomDialog(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: safeWidth < widget.maxWidth
                      ? safeWidth * 0.95
                      : widget.maxWidth,
                ),
                child: _aspectRatio == null
                    ? const Center(child: CircularProgressIndicator())
                    : AspectRatio(
                        aspectRatio: _aspectRatio!,
                        child: isNetworkImage
                            ? CachedNetworkImage(
                                imageUrl: widget.imagePath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.red, size: 60),
                              )
                            : Image.asset(
                                widget.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red, size: 60),
                              ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showZoomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: isNetworkImage
                  ? CachedNetworkImageProvider(widget.imagePath)
                  : AssetImage(widget.imagePath) as ImageProvider,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.5,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafeAvatar extends StatelessWidget {
  final String url;
  final double size;

  const SafeAvatar({
    super.key,
    required this.url,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return ClipOval(
        child: Image.asset(
          'assets/images/defaultprofile.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (url.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Icon(Icons.person, size: 40),
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        File(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/defaultprofile.jpg'),
      ),
    );
  }
}
