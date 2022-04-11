import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:future_of_egypt_client/models/chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Gallery extends StatefulWidget {
   Gallery({Key? key,required this.images,required this.index}) : super(key: key);
List<ChatModel> images ;
int index  ;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
          pageController: PageController(initialPage: widget.index),

          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider:CachedNetworkImageProvider(widget.images[index].fileName),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index].senderID),
            );
          },
          itemCount: widget.images.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
        )
    );
  }
}
