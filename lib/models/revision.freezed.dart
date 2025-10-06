// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Revision {

 String get id; String get projectId; String get version; String get description;@ChangesConverter() List<String> get changes; RevisionStatus get status; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Revision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevisionCopyWith<Revision> get copyWith => _$RevisionCopyWithImpl<Revision>(this as Revision, _$identity);

  /// Serializes this Revision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Revision&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.changes, changes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,version,description,const DeepCollectionEquality().hash(changes),status,createdAt,updatedAt);

@override
String toString() {
  return 'Revision(id: $id, projectId: $projectId, version: $version, description: $description, changes: $changes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RevisionCopyWith<$Res>  {
  factory $RevisionCopyWith(Revision value, $Res Function(Revision) _then) = _$RevisionCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String version, String description,@ChangesConverter() List<String> changes, RevisionStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$RevisionCopyWithImpl<$Res>
    implements $RevisionCopyWith<$Res> {
  _$RevisionCopyWithImpl(this._self, this._then);

  final Revision _self;
  final $Res Function(Revision) _then;

/// Create a copy of Revision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? version = null,Object? description = null,Object? changes = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RevisionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Revision].
extension RevisionPatterns on Revision {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Revision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Revision() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Revision value)  $default,){
final _that = this;
switch (_that) {
case _Revision():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Revision value)?  $default,){
final _that = this;
switch (_that) {
case _Revision() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String version,  String description, @ChangesConverter()  List<String> changes,  RevisionStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Revision() when $default != null:
return $default(_that.id,_that.projectId,_that.version,_that.description,_that.changes,_that.status,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String version,  String description, @ChangesConverter()  List<String> changes,  RevisionStatus status,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Revision():
return $default(_that.id,_that.projectId,_that.version,_that.description,_that.changes,_that.status,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String version,  String description, @ChangesConverter()  List<String> changes,  RevisionStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Revision() when $default != null:
return $default(_that.id,_that.projectId,_that.version,_that.description,_that.changes,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Revision extends Revision {
  const _Revision({required this.id, required this.projectId, required this.version, required this.description, @ChangesConverter() required final  List<String> changes, this.status = RevisionStatus.pending, required this.createdAt, required this.updatedAt}): _changes = changes,super._();
  factory _Revision.fromJson(Map<String, dynamic> json) => _$RevisionFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String version;
@override final  String description;
 final  List<String> _changes;
@override@ChangesConverter() List<String> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}

@override@JsonKey() final  RevisionStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Revision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevisionCopyWith<_Revision> get copyWith => __$RevisionCopyWithImpl<_Revision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Revision&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._changes, _changes)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,version,description,const DeepCollectionEquality().hash(_changes),status,createdAt,updatedAt);

@override
String toString() {
  return 'Revision(id: $id, projectId: $projectId, version: $version, description: $description, changes: $changes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RevisionCopyWith<$Res> implements $RevisionCopyWith<$Res> {
  factory _$RevisionCopyWith(_Revision value, $Res Function(_Revision) _then) = __$RevisionCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String version, String description,@ChangesConverter() List<String> changes, RevisionStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$RevisionCopyWithImpl<$Res>
    implements _$RevisionCopyWith<$Res> {
  __$RevisionCopyWithImpl(this._self, this._then);

  final _Revision _self;
  final $Res Function(_Revision) _then;

/// Create a copy of Revision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? version = null,Object? description = null,Object? changes = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Revision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RevisionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
