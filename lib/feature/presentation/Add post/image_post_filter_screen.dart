import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/sep_image_filter.dart';
import 'package:sep/components/styles/appColors.dart';

class ImagePostFilterScreen extends StatefulWidget {
  final File imageFile;

  const ImagePostFilterScreen({super.key, required this.imageFile});

  @override
  State<ImagePostFilterScreen> createState() => _ImagePostFilterScreenState();
}

class _ImagePostFilterScreenState extends State<ImagePostFilterScreen> {
  final GlobalKey _previewKey = GlobalKey();
  int _selectedPreset = 0;
  bool _applying = false;

  Future<void> _applyAndReturn() async {
    if (_applying) return;
    setState(() {
      _applying = true;
    });

    try {
      // Capture filtered image from RepaintBoundary
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        Navigator.of(context).pop<File?>(widget.imageFile);
        return;
      }

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final ui.Image image =
          await boundary.toImage(pixelRatio: pixelRatio.clamp(1.0, 3.0));
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        Navigator.of(context).pop<File?>(widget.imageFile);
        return;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final filteredFile = File(
        '${dir.path}/sep_filtered_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await filteredFile.writeAsBytes(pngBytes, flush: true);

      if (!mounted) return;
      Navigator.of(context).pop<File?>(filteredFile);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop<File?>(widget.imageFile);
    } finally {
      if (mounted) {
        setState(() {
          _applying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = EnhancementPresets.byIndex(_selectedPreset);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _applying ? null : () => Navigator.of(context).pop(),
        ),
        title: const TextView(
          text: 'Edit Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _applying ? null : _applyAndReturn,
            child: _applying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _previewKey,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SepImageFilter(
                    settings: settings,
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterRow(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final names = EnhancementPresets.names;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedPreset;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPreset = index;
              });
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.btnColor.withOpacity(0.18)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.btnColor : Colors.white24,
                  width: selected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.black,
                        child: EnhancementPresets.assetForIndex(index) != null
                            ? Image.asset(
                                EnhancementPresets.assetForIndex(index)!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.filter_alt,
                                size: 20,
                                color: Colors.white70,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    names[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

