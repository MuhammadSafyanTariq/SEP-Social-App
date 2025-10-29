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

class EditProfileImage2 extends StatelessWidget {
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

  const EditProfileImage2({
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
  });

  Widget imageView() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ImageView(
        radius: radius ?? 50,
        hasBorder: !hasGradient,
        bgColor: AppColors.white,
        url: imageData.type == ImageType.network
            ? imageData.network ?? ''
            : imageData.type == ImageType.file
            ? imageData.file!
            : img ?? AppImages.prifileImg,
        defaultImage: imageData.asset,
        tintColor: imageData.type == ImageType.network &&
            !(imageData.network?.isNotEmpty ?? false)
            ? tintColor
            : null,
        size: size,
        imageType: imageData.type,
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
          hasGradient
              ? GradientCard(
            radius: radius,
            height: size,
            width: size,
            child: imageView(),
          )
              : imageView(),
          Visibility(
            visible: isEditable,
            child: TapWidget(
              onTap: () {
                appBSheet(
                  context,
                  EditImageBSheetView(
                    onItemTap: (source) async {
                      Navigator.pop(context);
                      final path = await _imagePickerOpen(source);
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
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextView(
                  text: "Choose Photo",
                  style: 14.txtRegularBlack,
                ),
              ),
            ),
          ),
          if (error != null)
            TextView(
              text: error ?? '',
              style: 14.txtRegularError,
              margin: const EdgeInsets.only(top: 7),
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
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(size / 2),
            // border: Border.all(color: AppColors.primaryBlue,width: 2)
          ),
          child: Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 17,
          ),
          // child: const ImageView(
          //   url: AppIcons.editCamera,
          // ),
        ),
        Positioned.fill(
            child: TapWidget(
              onTap: onTap,
            ))
      ],
    );
  }
}



class EditImageBSheetView extends StatelessWidget {
  final Function(ImageSource) onItemTap;

  const EditImageBSheetView({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    // final locale = context.locale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20 )+ EdgeInsets.only(top: 10, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextView(
            margin: EdgeInsets.zero,
            text: "Choose Photo",
            style: 16.txtRegularBlack,
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              _ItemTile(
                  onTap: () => onItemTap(ImageSource.camera),
                  image: AppImages.camera,
                  name: "Camera"),
              const SizedBox(
                width: 20,
              ),
              _ItemTile(
                  onTap: () => onItemTap(ImageSource.gallery),
                  image: AppImages.gallery,
                  name: "Gallery"),
              // _ItemTile(onTap: ()=> onItemTap(ImageSource.camera),
              //     image: AppIcons.camera, name: locale.camera), const SizedBox(width: 20,),
              // _ItemTile(onTap: ()=> onItemTap(ImageSource.gallery),
              //     image: AppIcons.image, name: locale.gallery),
            ],
          )
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String image;
  final String name;
  final Function()? onTap;

  const _ItemTile(
      {required this.image, required this.name, this.onTap});

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
            TextView(
              text: name,
              style: 14.txtRegularBlack,
            ),
          ],
        ),
        Positioned.fill(
            child: TapWidget(
              onTap: onTap,
            ))
      ],
    );
  }
}


Future<String?> openCamera()=> _imagePickerOpen(ImageSource.camera);


Future<String?> openGallery()=> _imagePickerOpen(ImageSource.gallery);

Future<String?> _imagePickerOpen(ImageSource source) async{
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source);
  return image?.path;
}
