// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaqItemModelImpl _$$FaqItemModelImplFromJson(Map<String, dynamic> json) =>
    _$FaqItemModelImpl(
      id: json['id'] as String?,
      question: json['question'] as String?,
      answer: json['answer'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toInt(),
      isExpanded: json['isExpanded'] as bool?,
      showFullAnswer: json['showFullAnswer'] as bool?,
    );

Map<String, dynamic> _$$FaqItemModelImplToJson(_$FaqItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'v': instance.v,
      'isExpanded': instance.isExpanded,
      'showFullAnswer': instance.showFullAnswer,
    };
