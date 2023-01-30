import 'package:flutter/material.dart';

class DeletedMessage extends StatelessWidget {
  final String? message;
  final bool? isMe;

  DeletedMessage(this.message, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        message!,
        style: TextStyle(
            color: isMe!
                ? Colors.grey
                : Colors.grey,
            fontSize: 16),
        textAlign: isMe!
            ? TextAlign.end
            : TextAlign.start,
      ),
    );
  }
}