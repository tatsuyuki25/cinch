// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'example_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Global<T> {
  T get data;

  /// Create a copy of Global
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GlobalCopyWith<T, Global<T>> get copyWith =>
      _$GlobalCopyWithImpl<T, Global<T>>(this as Global<T>, _$identity);

  /// Serializes this Global to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Global<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'Global<$T>(data: $data)';
  }
}

/// @nodoc
abstract mixin class $GlobalCopyWith<T, $Res> {
  factory $GlobalCopyWith(Global<T> value, $Res Function(Global<T>) _then) =
      _$GlobalCopyWithImpl;
  @useResult
  $Res call({T data});
}

/// @nodoc
class _$GlobalCopyWithImpl<T, $Res> implements $GlobalCopyWith<T, $Res> {
  _$GlobalCopyWithImpl(this._self, this._then);

  final Global<T> _self;
  final $Res Function(Global<T>) _then;

  /// Create a copy of Global
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _Global<T> implements Global<T> {
  const _Global({required this.data});
  factory _Global.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$GlobalFromJson(json, fromJsonT);

  @override
  final T data;

  /// Create a copy of Global
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GlobalCopyWith<T, _Global<T>> get copyWith =>
      __$GlobalCopyWithImpl<T, _Global<T>>(this, _$identity);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$GlobalToJson<T>(this, toJsonT);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Global<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'Global<$T>(data: $data)';
  }
}

/// @nodoc
abstract mixin class _$GlobalCopyWith<T, $Res>
    implements $GlobalCopyWith<T, $Res> {
  factory _$GlobalCopyWith(_Global<T> value, $Res Function(_Global<T>) _then) =
      __$GlobalCopyWithImpl;
  @override
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$GlobalCopyWithImpl<T, $Res> implements _$GlobalCopyWith<T, $Res> {
  __$GlobalCopyWithImpl(this._self, this._then);

  final _Global<T> _self;
  final $Res Function(_Global<T>) _then;

  /// Create a copy of Global
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_Global<T>(
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

// dart format on
