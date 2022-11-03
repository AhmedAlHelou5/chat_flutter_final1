import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatImageView extends StatelessWidget {
  final String imageUrl;

  ChatImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        leading:  IconButton(
           icon: Icon(Icons.keyboard_backspace_outlined),
            color: Colors.white, onPressed: () {  Navigator.of(context).pop();},

        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: size.height,
            width: size.width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
