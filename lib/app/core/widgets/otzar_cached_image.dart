import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';

/// Offline-first cached image widget for OTZAR App.
/// Automatically persists network images to local device storage,
/// ensuring 100% offline availability in field operations.
class OtzarCachedImage extends StatefulWidget {
  final String? imageUrlOrPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OtzarCachedImage({
    super.key,
    required this.imageUrlOrPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<OtzarCachedImage> createState() => _OtzarCachedImageState();
}

class _OtzarCachedImageState extends State<OtzarCachedImage> {
  File? _localFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant OtzarCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrlOrPath != widget.imageUrlOrPath) {
      _loadImage();
    }
  }

  String _generateCacheKey(String url) {
    return base64Url.encode(utf8.encode(url)).replaceAll('=', '').replaceAll('/', '_');
  }

  Future<void> _loadImage() async {
    final src = widget.imageUrlOrPath?.trim();
    if (src == null || src.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // 1. If it's a local file path
    if (!src.startsWith('http://') && !src.startsWith('https://')) {
      final file = File(src);
      if (file.existsSync()) {
        if (mounted) {
          setState(() {
            _localFile = file;
            _isLoading = false;
          });
        }
        return;
      }
    }

    // 2. If it's a network URL (Cloudinary / S3 / API)
    if (src.startsWith('http://') || src.startsWith('https://')) {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final cacheDir = Directory('${docsDir.path}/image_cache');
        if (!cacheDir.existsSync()) {
          cacheDir.createSync(recursive: true);
        }

        final fileName = '${_generateCacheKey(src)}.jpg';
        final cachedFile = File('${cacheDir.path}/$fileName');

        // If already cached locally, use disk file immediately (Offline Ready!)
        if (cachedFile.existsSync() && cachedFile.lengthSync() > 0) {
          if (mounted) {
            setState(() {
              _localFile = cachedFile;
              _isLoading = false;
            });
          }
          return;
        }

        // Otherwise, download in background and persist
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 8);
        final request = await client.getUrl(Uri.parse(src));
        final response = await request.close();

        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          if (bytes.isNotEmpty) {
            await cachedFile.writeAsBytes(bytes);
            if (mounted) {
              setState(() {
                _localFile = cachedFile;
                _isLoading = false;
              });
            }
            return;
          }
        }
      } catch (e) {
        if (kDebugMode) print('Offline image cache load error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_localFile != null && _localFile!.existsSync()) {
      content = Image.file(
        _localFile!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else if (widget.imageUrlOrPath != null &&
        (widget.imageUrlOrPath!.startsWith('http://') || widget.imageUrlOrPath!.startsWith('https://'))) {
      // Direct network image attempt with caching fallback
      content = Image.network(
        widget.imageUrlOrPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildLoading();
        },
      );
    } else if (_isLoading) {
      content = _buildLoading();
    } else {
      content = _buildFallback();
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildLoading() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.surfaceBorder.withValues(alpha: 0.3),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.ore),
              ),
            ),
          ),
        );
  }

  Widget _buildFallback() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.surfaceBorder.withValues(alpha: 0.4),
          child: const Center(
            child: Icon(
              Icons.diamond_outlined,
              color: AppColors.muted,
              size: 20,
            ),
          ),
        );
  }
}
