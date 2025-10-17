import 'dart:ui';

import 'package:flutter/material.dart';

class CommonModel{
  String? title;
  String? key;
  String? subtitle;
  String? description;
  String? image;
  String? search;
  String? category;
  VoidCallback? onTap;
  Widget? child;
  bool? isSelected;
  CommonModel({this.title,
    this.key,
    this.image,this.subtitle,this.description,this.onTap,this.child,
    this.isSelected = false,
    this.search,
    this.category
  });
}