

import 'package:equatable/equatable.dart';


class DropDownModel extends Equatable {
  final String? en;
  final String? hi;
  final String? keyValue;

  const DropDownModel(
      { this.en,
        this.hi,
        this.keyValue,});

  @override
  List<Object?> get props => [
    en,hi,keyValue
  ];
}
