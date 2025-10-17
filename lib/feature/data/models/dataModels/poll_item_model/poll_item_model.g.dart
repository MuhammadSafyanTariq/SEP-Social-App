// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PollItemModelImpl _$$PollItemModelImplFromJson(Map<String, dynamic> json) =>
    _$PollItemModelImpl(
      name: json['name'] as String?,
      image: json['image'] as String?,
      file: json['file'] as String?,
      isValid: json['isValid'] as bool?,
    );

Map<String, dynamic> _$$PollItemModelImplToJson(_$PollItemModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
      'file': instance.file,
      'isValid': instance.isValid,
    };
