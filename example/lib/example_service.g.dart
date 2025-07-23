// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Global<T> _$GlobalFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _Global<T>(data: fromJsonT(json['data']));

Map<String, dynamic> _$GlobalToJson<T>(
  _Global<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'data': toJsonT(instance.data)};
