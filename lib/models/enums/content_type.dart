import 'package:hive/hive.dart';

part 'content_type.g.dart';

@HiveType(typeId: 2)
enum ContentType {
  @HiveField(0)
  text,
  @HiveField(1)
  markdown,
  @HiveField(2)
  code,
  @HiveField(3)
  image,
  @HiveField(4)
  link,
  @HiveField(5)
  document,
}

extension ContentTypeX on ContentType {
  String get label {
    switch (this) {
      case ContentType.text:
        return 'Text';
      case ContentType.markdown:
        return 'Markdown';
      case ContentType.code:
        return 'Code';
      case ContentType.image:
        return 'Image';
      case ContentType.link:
        return 'Link';
      case ContentType.document:
        return 'Document';
    }
  }
}
