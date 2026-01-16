import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/styles/textStyles.dart';
import '../../core/core/model/imageDataModel.dart';
import '../../feature/presentation/widgets/gradient_card.dart';
import '../styles/appColors.dart';
import '../styles/appImages.dart';
import 'ImageView.dart';
import 'TapWidget.dart';
import 'TextView.dart';
import 'appBSheet.dart';

class EditProfileImage extends StatelessWidget {
  final double size;
  final ImageDataModel imageData;
  final Function(ImageDataModel)? onChange;
  final bool isEditable;
  final EdgeInsets? margin;
  final String? error;
  final String? img;
  final double? radius;
  final Color? tintColor;
  final bool hasGradient;
  final Gradient? gradient;
  final Function()? onImageTap;

  const EditProfileImage({
    super.key,
    required this.size,
    required this.imageData,
    this.onChange,
    this.isEditable = true,
    this.margin,
    this.radius,
    this.hasGradient = false,
    this.error,
    this.img,
    this.tintColor,
    this.gradient,
    this.onImageTap,
  });

  Widget imageView() {
    String _getImageUrl() {
      if (imageData.type == ImageType.network &&
          (imageData.network?.isNotEmpty ?? false)) {
        return imageData.network!;
      } else if (imageData.type == ImageType.file &&
          (imageData.file?.isNotEmpty ?? false)) {
        return imageData.file!;
      } else if (img?.isNotEmpty ?? false) {
        return img!;
      } else {
        // return 'assets/images/dummy.png';  // Fallback to dummy image
        return AppImages.dummyProfile; // Fallback to dummy image
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ImageView(
        radius: radius ?? 60,
        hasBorder: !hasGradient,
        bgColor: AppColors.white,
        url: _getImageUrl(), // Extracted logic for better readability
        defaultImage: imageData.asset,
        tintColor:
            imageData.type == ImageType.network &&
                !(imageData.network?.isNotEmpty ?? false)
            ? tintColor
            : null,
        size: size,
        imageType: imageData.type,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              hasGradient
                  ? InkWell(
                      onTap: onImageTap,
                      child: GradientCard(
                        radius: radius,
                        height: size,
                        width: size,
                        child: imageView(),
                      ),
                    )
                  : imageView(),
              Positioned(
                right: isEditable ? 35 : null,
                bottom: isEditable ? 0 : null,
                child: Visibility(
                  visible: isEditable,
                  child: ImageEditButton(
                    size: 32,
                    onTap: () {
                      appBSheet(
                        context,
                        EditImageBSheetView(
                          onItemTap: (source) async {
                            Navigator.pop(context);
                            final path = await openFilePicker(source);
                            if (path != null) {
                              ImageDataModel imageDataTemp = imageData;
                              imageDataTemp.file = path;
                              imageDataTemp.type = ImageType.file;
                              if (onChange != null) {
                                onChange!(imageDataTemp);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            child: error != null
                ? TextView(
                    text: error ?? '',
                    style: 14.txtRegularError,
                    margin: const EdgeInsets.only(top: 7),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class ImageEditButton extends StatelessWidget {
  final double size;
  final Function()? onTap;

  const ImageEditButton({super.key, required this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapWidget(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}

class EditImageBSheetView extends StatelessWidget {
  final Function(MediaSource) onItemTap;
  final bool hasVideoPicker;

  const EditImageBSheetView({
    super.key,
    required this.onItemTap,
    this.hasVideoPicker = false,
  });

  @override
  Widget build(BuildContext context) {
    // final locale = context.locale;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20) +
          EdgeInsets.only(top: 10, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextView(
            margin: EdgeInsets.zero,
            text: "Choose ${hasVideoPicker ? 'File' : 'Photo'}",
            style: 16.txtRegularprimary,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _ItemTile(
                onTap: () => onItemTap(MediaSource.cameraPhoto),
                image: AppImages.cemaraaa,
                name: "Camera",
              ),
              const SizedBox(width: 20),
              _ItemTile(
                onTap: () => onItemTap(MediaSource.gallery),
                image: AppImages.gallaryy,
                name: "Gallery",
              ),

              Visibility(
                visible: hasVideoPicker,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    _ItemTile(
                      onTap: () => onItemTap(MediaSource.video),
                      image: AppImages.video,
                      name: "Video",
                    ),
                  ],
                ),
              ),

              // _ItemTile(onTap: ()=> onItemTap(ImageSource.camera),
              //     image: AppIcons.camera, name: locale.camera), const SizedBox(width: 20,),
              // _ItemTile(onTap: ()=> onItemTap(ImageSource.gallery),
              //     image: AppIcons.image, name: locale.gallery),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String image;
  final String name;
  final Function()? onTap;

  const _ItemTile({required this.image, required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ImageView(
              url: image,
              size: 40,
              tintColor: AppColors.grey,
              margin: const EdgeInsets.only(bottom: 5),
            ),
            TextView(text: name, style: 14.txtRegularprimary),
          ],
        ),
        Positioned.fill(child: TapWidget(onTap: onTap)),
      ],
    );
  }
}

Future<String?> openCameraPhoto() => openFilePicker(MediaSource.cameraPhoto);
Future<String?> openGallery() => openFilePicker(MediaSource.gallery);
Future<String?> openVideo() => openFilePicker(MediaSource.video);
Future<String?> openCameraVideo() => openFilePicker(MediaSource.cameraVideo);
// Future<String?> openGallery()=> _imagePickerOpen(ImageSource.gallery);

Future<String?> openFilePicker(MediaSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await (source.isPhoto
      ? picker.pickImage(source: source.imageSource)
      : picker.pickVideo(source: source.videoSource));
  return image?.path;
}

enum MediaSource { cameraPhoto, gallery, cameraVideo, video }

extension OnMediaSource on MediaSource {
  bool get isPhoto =>
      this == MediaSource.cameraPhoto || this == MediaSource.gallery;
  bool get isVideo =>
      this == MediaSource.video || this == MediaSource.cameraVideo;
  ImageSource get imageSource => this == MediaSource.cameraPhoto
      ? ImageSource.camera
      : ImageSource.gallery;
  ImageSource get videoSource => this == MediaSource.cameraVideo
      ? ImageSource.camera
      : ImageSource.gallery;
  String get fileType => isPhoto ? 'image' : 'video';
}
