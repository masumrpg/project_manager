// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

 String get id; String get userId; String get title; String? get description;@LongDescriptionConverter() String? get longDescription; AppCategory get category; Environment get environment; DateTime get createdAt; DateTime get updatedAt;@JsonKey(ignore: true) List<Note> get notes;@JsonKey(ignore: true) List<Revision> get revisions;@JsonKey(ignore: true) List<Todo> get todos; int? get notesCount; int? get todosCount; int? get revisionsCount; int? get completedTodosCount;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.longDescription, longDescription) || other.longDescription == longDescription)&&(identical(other.category, category) || other.category == category)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.revisions, revisions)&&const DeepCollectionEquality().equals(other.todos, todos)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&(identical(other.todosCount, todosCount) || other.todosCount == todosCount)&&(identical(other.revisionsCount, revisionsCount) || other.revisionsCount == revisionsCount)&&(identical(other.completedTodosCount, completedTodosCount) || other.completedTodosCount == completedTodosCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,description,longDescription,category,environment,createdAt,updatedAt,const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(revisions),const DeepCollectionEquality().hash(todos),notesCount,todosCount,revisionsCount,completedTodosCount);

@override
String toString() {
  return 'Project(id: $id, userId: $userId, title: $title, description: $description, longDescription: $longDescription, category: $category, environment: $environment, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, revisions: $revisions, todos: $todos, notesCount: $notesCount, todosCount: $todosCount, revisionsCount: $revisionsCount, completedTodosCount: $completedTodosCount)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String title, String? description,@LongDescriptionConverter() String? longDescription, AppCategory category, Environment environment, DateTime createdAt, DateTime updatedAt,@JsonKey(ignore: true) List<Note> notes,@JsonKey(ignore: true) List<Revision> revisions,@JsonKey(ignore: true) List<Todo> todos, int? notesCount, int? todosCount, int? revisionsCount, int? completedTodosCount
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? description = freezed,Object? longDescription = freezed,Object? category = null,Object? environment = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = null,Object? revisions = null,Object? todos = null,Object? notesCount = freezed,Object? todosCount = freezed,Object? revisionsCount = freezed,Object? completedTodosCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,longDescription: freezed == longDescription ? _self.longDescription : longDescription // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AppCategory,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as Environment,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<Note>,revisions: null == revisions ? _self.revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<Revision>,todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<Todo>,notesCount: freezed == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int?,todosCount: freezed == todosCount ? _self.todosCount : todosCount // ignore: cast_nullable_to_non_nullable
as int?,revisionsCount: freezed == revisionsCount ? _self.revisionsCount : revisionsCount // ignore: cast_nullable_to_non_nullable
as int?,completedTodosCount: freezed == completedTodosCount ? _self.completedTodosCount : completedTodosCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  String? description, @LongDescriptionConverter()  String? longDescription,  AppCategory category,  Environment environment,  DateTime createdAt,  DateTime updatedAt, @JsonKey(ignore: true)  List<Note> notes, @JsonKey(ignore: true)  List<Revision> revisions, @JsonKey(ignore: true)  List<Todo> todos,  int? notesCount,  int? todosCount,  int? revisionsCount,  int? completedTodosCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.description,_that.longDescription,_that.category,_that.environment,_that.createdAt,_that.updatedAt,_that.notes,_that.revisions,_that.todos,_that.notesCount,_that.todosCount,_that.revisionsCount,_that.completedTodosCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  String? description, @LongDescriptionConverter()  String? longDescription,  AppCategory category,  Environment environment,  DateTime createdAt,  DateTime updatedAt, @JsonKey(ignore: true)  List<Note> notes, @JsonKey(ignore: true)  List<Revision> revisions, @JsonKey(ignore: true)  List<Todo> todos,  int? notesCount,  int? todosCount,  int? revisionsCount,  int? completedTodosCount)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.userId,_that.title,_that.description,_that.longDescription,_that.category,_that.environment,_that.createdAt,_that.updatedAt,_that.notes,_that.revisions,_that.todos,_that.notesCount,_that.todosCount,_that.revisionsCount,_that.completedTodosCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String title,  String? description, @LongDescriptionConverter()  String? longDescription,  AppCategory category,  Environment environment,  DateTime createdAt,  DateTime updatedAt, @JsonKey(ignore: true)  List<Note> notes, @JsonKey(ignore: true)  List<Revision> revisions, @JsonKey(ignore: true)  List<Todo> todos,  int? notesCount,  int? todosCount,  int? revisionsCount,  int? completedTodosCount)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.description,_that.longDescription,_that.category,_that.environment,_that.createdAt,_that.updatedAt,_that.notes,_that.revisions,_that.todos,_that.notesCount,_that.todosCount,_that.revisionsCount,_that.completedTodosCount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Project extends Project {
  const _Project({required this.id, required this.userId, required this.title, this.description, @LongDescriptionConverter() this.longDescription, required this.category, required this.environment, required this.createdAt, required this.updatedAt, @JsonKey(ignore: true) final  List<Note> notes = const <Note>[], @JsonKey(ignore: true) final  List<Revision> revisions = const <Revision>[], @JsonKey(ignore: true) final  List<Todo> todos = const <Todo>[], this.notesCount, this.todosCount, this.revisionsCount, this.completedTodosCount}): _notes = notes,_revisions = revisions,_todos = todos,super._();
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String title;
@override final  String? description;
@override@LongDescriptionConverter() final  String? longDescription;
@override final  AppCategory category;
@override final  Environment environment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<Note> _notes;
@override@JsonKey(ignore: true) List<Note> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

 final  List<Revision> _revisions;
@override@JsonKey(ignore: true) List<Revision> get revisions {
  if (_revisions is EqualUnmodifiableListView) return _revisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revisions);
}

 final  List<Todo> _todos;
@override@JsonKey(ignore: true) List<Todo> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

@override final  int? notesCount;
@override final  int? todosCount;
@override final  int? revisionsCount;
@override final  int? completedTodosCount;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.longDescription, longDescription) || other.longDescription == longDescription)&&(identical(other.category, category) || other.category == category)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._revisions, _revisions)&&const DeepCollectionEquality().equals(other._todos, _todos)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&(identical(other.todosCount, todosCount) || other.todosCount == todosCount)&&(identical(other.revisionsCount, revisionsCount) || other.revisionsCount == revisionsCount)&&(identical(other.completedTodosCount, completedTodosCount) || other.completedTodosCount == completedTodosCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,description,longDescription,category,environment,createdAt,updatedAt,const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_revisions),const DeepCollectionEquality().hash(_todos),notesCount,todosCount,revisionsCount,completedTodosCount);

@override
String toString() {
  return 'Project(id: $id, userId: $userId, title: $title, description: $description, longDescription: $longDescription, category: $category, environment: $environment, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, revisions: $revisions, todos: $todos, notesCount: $notesCount, todosCount: $todosCount, revisionsCount: $revisionsCount, completedTodosCount: $completedTodosCount)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String title, String? description,@LongDescriptionConverter() String? longDescription, AppCategory category, Environment environment, DateTime createdAt, DateTime updatedAt,@JsonKey(ignore: true) List<Note> notes,@JsonKey(ignore: true) List<Revision> revisions,@JsonKey(ignore: true) List<Todo> todos, int? notesCount, int? todosCount, int? revisionsCount, int? completedTodosCount
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? description = freezed,Object? longDescription = freezed,Object? category = null,Object? environment = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = null,Object? revisions = null,Object? todos = null,Object? notesCount = freezed,Object? todosCount = freezed,Object? revisionsCount = freezed,Object? completedTodosCount = freezed,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,longDescription: freezed == longDescription ? _self.longDescription : longDescription // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AppCategory,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as Environment,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<Note>,revisions: null == revisions ? _self._revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<Revision>,todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<Todo>,notesCount: freezed == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int?,todosCount: freezed == todosCount ? _self.todosCount : todosCount // ignore: cast_nullable_to_non_nullable
as int?,revisionsCount: freezed == revisionsCount ? _self.revisionsCount : revisionsCount // ignore: cast_nullable_to_non_nullable
as int?,completedTodosCount: freezed == completedTodosCount ? _self.completedTodosCount : completedTodosCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
