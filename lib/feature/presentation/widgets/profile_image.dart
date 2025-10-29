import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TapWidget.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/agora_chat_ctrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';

import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appImages.dart';
import 'dart:ui' as ui;

class ProfileImage extends StatelessWidget {
  final String? image;
  final String? uid;
  final double? size;
  final bool socketConnection;
  final Function()? onTap;



  const ProfileImage(
      {super.key,
      this.image,
      this.size,
      this.onTap,
      this.uid,
      required this.socketConnection});

  @override
  Widget build(BuildContext context) {
    final hasImage = image.isNotNullEmpty;
    final imgSize = size ?? 80.sdp;
    return Obx(
      () {
        final liveIndex = AgoraChatCtrl.find.liveStreamChannels
            .indexWhere((element) => element.hostId == uid);
        final isLive = liveIndex > -1;
        return Stack(
          children: [
            GradientRing(
                size: imgSize + (isLive ? 4 : 0),
                strokeWidth: isLive ? 4 : 0,
                colors: [
                  Colors.blue,
                  Colors.purple,
                  Colors.blue,
                ],
                child: ImageView(
                  url: image ?? AppImages.dummyProfile,
                  size: imgSize,
                  defaultImage: AppImages.dummyProfile,
                  imageType: hasImage ? ImageType.network : null,
                  radius: imgSize / 2,
                  fit: BoxFit.cover,
                )),
            Positioned.fill(child: TapWidget(onTap: (){
              void joinLive() {
                AgoraChatCtrl.find.joinLiveChannel(
                    AgoraChatCtrl.find.liveStreamChannels[liveIndex],null,
                    socketConnection,
                        (value) {});
              }

              // If both live and has image
              if (isLive && hasImage && onTap != null) {
                context.openDialog(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: 'View profile image',
                        style: 16.txtBoldBlack,
                        onTap: () {
                          context.stopLoader;
                          onTap?.call();
                        }
                      ),
                      SizedBox(height: 20),
                      TextView(
                        text: 'Join Live Session',
                        style: 16.txtBoldBlack,
                        onTap: () {
                          joinLive();
                          context.stopLoader;
                        },
                      ),
                    ],
                  ),
                );
                return;
              }

              // If not live, but image exists
              if (hasImage && onTap != null) {
                onTap?.call();
                return;
              }

              // If live but no image
              if (isLive) {
                joinLive();
                return;
              }

            }))
          ],
        );
      },
    );
  }
}

class GradientRing extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final List<Color> colors;
  final Widget child;

  const GradientRing(
      {super.key,
      this.size = 100,
      this.strokeWidth = 8,
      this.colors = const [Colors.blue, Colors.purple],
      required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (child != null) child!,
          if (strokeWidth > 0)
            CustomPaint(
              size: ui.Size.square(size),
              painter: _RingPainter(
                strokeWidth: strokeWidth,
                gradientColors: colors,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double strokeWidth;
  final List<Color> gradientColors;

  _RingPainter({required this.strokeWidth, required this.gradientColors});

  @override
  void paint(Canvas canvas, ui.Size size) {
    if (strokeWidth <= 0) return;
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0.0,
        endAngle: 3.14 * 2,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final double radius = (size.width / 2) - (strokeWidth / 2);
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




