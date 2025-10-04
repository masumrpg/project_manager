enum AppCategory { web, mobile, desktop, api, other }

extension AppCategoryX on AppCategory {
  String get label {
    switch (this) {
      case AppCategory.web:
        return 'Web';
      case AppCategory.mobile:
        return 'Mobile';
      case AppCategory.desktop:
        return 'Desktop';
      case AppCategory.api:
        return 'API';
      case AppCategory.other:
        return 'Lainnya';
    }
  }

  String get apiValue {
    switch (this) {
      case AppCategory.web:
        return 'web';
      case AppCategory.mobile:
        return 'mobile';
      case AppCategory.desktop:
        return 'desktop';
      case AppCategory.api:
        return 'api';
      case AppCategory.other:
        return 'other';
    }
  }

  static AppCategory fromApiValue(String value) {
    switch (value) {
      case 'web':
        return AppCategory.web;
      case 'mobile':
        return AppCategory.mobile;
      case 'desktop':
        return AppCategory.desktop;
      case 'api':
        return AppCategory.api;
      default:
        return AppCategory.other;
    }
  }
}
