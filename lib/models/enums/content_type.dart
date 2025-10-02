enum ContentType { text, markdown, code, image, link, document }

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

  static ContentType fromApiValue(String value) {
    switch (value) {
      case 'markdown':
        return ContentType.markdown;
      case 'code':
        return ContentType.code;
      case 'image':
        return ContentType.image;
      case 'link':
        return ContentType.link;
      case 'document':
        return ContentType.document;
      case 'text':
      default:
        return ContentType.text;
    }
  }

  String get apiValue {
    switch (this) {
      case ContentType.text:
        return 'text';
      case ContentType.markdown:
        return 'markdown';
      case ContentType.code:
        return 'code';
      case ContentType.image:
        return 'image';
      case ContentType.link:
        return 'link';
      case ContentType.document:
        return 'document';
    }
  }
}
