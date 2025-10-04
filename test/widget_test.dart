// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:catatan_kaki/main.dart';
import 'package:catatan_kaki/services/api_client.dart';
import 'package:catatan_kaki/services/auth_service.dart';
import 'package:catatan_kaki/services/auth_storage.dart';
import 'package:catatan_kaki/screens/home_screen.dart';
import 'package:catatan_kaki/models/user.dart';

void main() {
  testWidgets('Home screen renders base layout', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await AuthStorage.create();
    await storage.saveToken('test-token');
    await storage.saveUser(
      const User(
        id: 'user_1',
        email: 'tester@example.com',
        name: 'Tester',
        role: 'QA',
      ),
    );
    final apiClient = _FakeApiClient(storage);
    final authService = AuthService(apiClient: apiClient, storage: storage);

    await tester.pumpWidget(ProjectManagerApp(
      apiClient: apiClient,
      authService: authService,
    ));

    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(AuthStorage storage)
      : super(baseUrl: 'https://fake.api', authStorage: storage);

  @override
  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) async {
    if (path == '/api/auth/get-session') {
      return {
        'user': {
          'id': 'user_1',
          'email': 'tester@example.com',
          'name': 'Tester',
          'role': 'QA',
        }
      };
    }

    if (path == '/api/projects') {
      final now = DateTime.now().toUtc().toIso8601String();
      return {
        'data': [
          {
            'id': 'proj_1',
            'userId': 'user_1',
            'title': 'Demo Project',
            'description': 'Testing sync flow',
            'longDescription': null,
            'category': 'web',
            'environment': 'development',
            'createdAt': now,
            'updatedAt': now,
          }
        ]
      };
    }

    if (path == '/api/statistics') {
      return {
        'projectsCount': 1,
        'noteCount': 0,
        'todoCount': 0,
        'revisionsCount': 0,
      };
    }

    if (path == '/api/projects/proj_1') {
      final now = DateTime.now().toUtc().toIso8601String();
      return {
        'data': {
          'id': 'proj_1',
          'userId': 'user_1',
          'title': 'Demo Project',
          'description': 'Testing sync flow',
          'longDescription': null,
          'category': 'web',
          'environment': 'development',
          'createdAt': now,
          'updatedAt': now,
        },
        'stats': {
          'notes': 0,
          'todos': 0,
          'revisions': 0,
          'completedTodos': 0,
        },
      };
    }

    if (path.startsWith('/api/projects/proj_1/')) {
      return {'data': []};
    }

    return {'data': []};
  }

  @override
  Future<dynamic> post(String path,
      {Map<String, String>? queryParameters, Object? body}) async {
    return {};
  }

  @override
  Future<dynamic> patch(String path,
      {Map<String, String>? queryParameters, Object? body}) async {
    return {};
  }

  @override
  Future<dynamic> delete(String path,
      {Map<String, String>? queryParameters, Object? body}) async {
    return {};
  }
}
