import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../screen/chat_image_view.dart';

class TextWithImage extends StatefulWidget {
  final String? imageUrl;
  final String? message;
  final bool? isMe;

  TextWithImage(this.imageUrl, this.message, this.isMe);

  @override
  State<TextWithImage> createState() => _TextWithImageState();
}



class _TextWithImageState extends State<TextWithImage> {


  void _saveNetworkImage() async {
    String path =widget.imageUrl!;
   await GallerySaver.saveImage(path);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        width:150 ,
        child: GestureDetector(
          onTap: () {
            _saveNetworkImage();

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatImageView(
                      imageUrl: widget.imageUrl!,
                    )));
          },
          child: Column(
              crossAxisAlignment:
                  widget.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [

                CachedNetworkImage(
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                    value: downloadProgress.progress,
                    strokeWidth: 4,
                  ),
                  fadeInCurve: Curves.bounceIn,
                  imageUrl: widget.imageUrl!,
                  fit: BoxFit.contain,
                  fadeOutDuration: const Duration(seconds: 1),

                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    widget.message!,
                    style: TextStyle(
                        color: widget.isMe!
                            ? Colors.black
                            : Theme.of(context).textTheme.headline6!.color,
                        fontSize: 16),
                    textAlign: widget.isMe! ? TextAlign.end : TextAlign.start,
                  ),
                ),
              ]),
        ),
      ),
    );
  }


}