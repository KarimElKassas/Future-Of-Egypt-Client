import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'gallery_item_model.dart';

// to show image in Row
class GalleryThumbnail extends StatelessWidget {
  const GalleryThumbnail({Key? key, required this.galleryItem, this.onTap})
      : super(key: key);

  final GalleryModel galleryItem;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: galleryItem.imageUrl.path,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: galleryItem.imageUrl.path.toString().replaceAll("[", "").replaceAll("]", ""),
          height: 100.0,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 0.8,)),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}