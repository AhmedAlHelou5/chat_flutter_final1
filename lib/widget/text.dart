import 'package:flutter/material.dart';

class TextMessage extends StatelessWidget {
  final String? message;
  final bool? isMe;

  TextMessage(this.message, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
       message!,
        style: TextStyle(
            color: isMe!
                ? Colors.black
                : Theme.of(context)
                .textTheme
                .headline6!
                .color,
            fontSize: 16),
        textAlign: isMe!
            ? TextAlign.end
            : TextAlign.start,
      ),
    );
  }
}