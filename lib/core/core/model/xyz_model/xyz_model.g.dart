// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xyz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$XyzModelImpl _$$XyzModelImplFromJson(Map<String, dynamic> json) =>
    _$XyzModelImpl(
      greeting: json['greeting'] as String?,
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      newId: (json['newId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$XyzModelImplToJson(_$XyzModelImpl instance) =>
    <String, dynamic>{
      'greeting': instance.greeting,
      'instructions': instance.instructions,
      'newId': instance.newId,
    };
