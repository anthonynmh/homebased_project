import 'dart:io';
import 'package:flutter/material.dart';

class ImageScroller extends StatelessWidget {
  final List<String> imagePaths;
  final double height;
  final double spacing;
  final BorderRadius borderRadius;

  const ImageScroller({
    super.key,
    required this.imagePaths,
    this.height = 120,
    this.spacing = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox(
        child: Text('No images uploaded'),
      ); // No images → render nothing
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final path = imagePaths[index];
          final isAsset = !path.startsWith(
            '/',
          ); // crude check for assets vs local files

          return ClipRRect(
            borderRadius: borderRadius,
            child: isAsset
                ? Image.asset(
                    path,
                    fit: BoxFit.cover,
                    height: height,
                    width: height * 1.5,
                  )
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    height: height,
                    width: height * 1.5,
                  ),
          );
        },
      ),
    );
  }
}
