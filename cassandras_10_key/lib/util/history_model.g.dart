// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History(
      value: (json['value'] as num?)?.toDouble() ?? 0,
      isTotal: json['isTotal'] as bool? ?? false,
      isClear: json['isClear'] as bool? ?? false,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    );

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
      'value': instance.value,
      'isTotal': instance.isTotal,
      'isClear': instance.isClear,
      'createdDate': instance.createdDate.toIso8601String(),
    };
