import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../data/models/dataModels/post_data.dart';
import '../Home/like_Screen.dart';
class FavButton extends StatefulWidget {
  final bool initialState; // Initial like state (isLikedByUser)
  final int initialCount; // Initial like count
  final Function() onTap; // Function to handle the like/unlike action
  final String postId;

  FavButton({
    super.key,
    required this.initialState,
    required this.initialCount,
    required this.onTap,
    required this.postId,
  });

  @override
  _FavButtonState createState() => _FavButtonState();
}

class _FavButtonState extends State<FavButton> {
  // late bool isLiked;
  // late int likeCount;

  @override
  void initState() {
    super.initState();
    // Set initial like state based on `isLikedByUser` (initialState)
    // isLiked = widget.initialState; // This could be false or true based on your data
    // likeCount = widget.initialCount;
  }

  Future<void> _toggleLike() async {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleLike,
          child: ImageView(
            url: widget.initialState
                ? AppImages.heartfillImage
                : "assets/images/Vectorlikeempty.png",
            size: 20,
          ),
        ),
        const SizedBox(width: 5),
        TextView(
          text: '${widget.initialCount}',
          style: 12.txtRegularprimary,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: LikeScreen(postId: widget.postId),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: TextView(
              text: "Likes",
              style: 12.txtRegularGrey,
            ),
          ),
        ),
      ],
    );
  }
}
