import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final ValueNotifier<bool> isLikedNotifier;
  final Function(bool) onLikeChanged;

  LikeButton({Key? key, bool initialLiked = false, required this.onLikeChanged})
      : isLikedNotifier = ValueNotifier<bool>(initialLiked),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLikedNotifier,
      builder: (context, isLiked, child) {
        return IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            isLikedNotifier.value = !isLikedNotifier.value;
            onLikeChanged(isLikedNotifier.value);
          },
        );
      },
    );
  }
}
