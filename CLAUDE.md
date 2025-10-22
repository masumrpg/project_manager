# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Catatan Kaki** is a Flutter application for coordinating projects, notes, revisions, and todos through a streamlined interface connected to a remote API. The app follows Clean Architecture with Provider state management.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Run for Linux desktop specifically
flutter run -d linux

# Build for production (Linux)
flutter build linux --release

# Build Debian package (uses helper script)
./tool/package_linux.sh

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Generate app icons (if assets/images/logo.png changes)
flutter pub run flutter_launcher_icons:main
```

### Environment Setup
- Copy `.env.example` to `.env` and set `BASE_URL` to the API endpoint
- Current production API: `https://project_manager_api_hono.mclasix.workers.dev`
- Run `flutter pub get` after changing `.env` to reload assets

## Architecture Overview

### Core Architecture Patterns
- **Clean Architecture** with clear separation of concerns
- **Provider Pattern** for state management (AuthProvider, ProjectProvider, ProjectDetailProvider)
- **Repository Pattern** for data access abstraction
- **GoRouter** for declarative routing with authentication guards
- **Service Layer** for business logic (AuthService, ApiClient)

### Key Directories Structure
```
lib/
├── main.dart                    # App entry point - initializes services and providers
├── router/app_router.dart       # GoRouter configuration with auth guards
├── models/                      # Data models with JSON serialization
│   ├── project.dart            # Project entity with category/environment enums
│   ├── note.dart               # Note entity with rich text content
│   ├── todo.dart               # Todo entity with priority and due dates
│   ├── revision.dart           # Revision entity with version tracking
│   └── user.dart               # User entity for authentication
├── providers/                   # State management
│   ├── auth_provider.dart      # Authentication and session management
│   ├── project_provider.dart   # Global project state
│   └── project_detail_provider.dart # Project-specific CRUD operations
├── repositories/                # Data access layer
│   └── project_repository.dart # API abstraction layer
├── services/                    # Business logic and external integrations
│   ├── api_client.dart         # HTTP client with auth headers
│   ├── auth_service.dart       # Authentication logic
│   ├── auth_storage.dart       # Secure token persistence
│   └── http_overrides.dart     # SSL certificate handling
├── screens/                     # UI screens (one per major feature)
└── widgets/                     # Reusable UI components
    ├── shared/                 # Common widgets across screens
    └── project_detail/         # Project detail specific widgets
```

### Application Flow
1. **SplashScreen** → check stored credentials
2. **AuthScreen** → if no valid session (email/password auth)
3. **HomeScreen** → project dashboard with metrics
4. **ProjectDetailScreen** → central hub for notes/todos/revisions
5. **Detail/Edit Screens** → CRUD operations for each entity type

### Data Models & Relationships
- **USER** → owns many **PROJECT**
- **PROJECT** → has many **NOTE**, **TODO**, **REVISION**
- All entities have: `id`, `title`, `description`, `status`, timestamps
- Rich text content stored as JSON (Flutter Quill format)
- Status workflows: Draft→Active→Archived, Pending→In Progress→Completed

### State Management Patterns
- **AuthProvider**: Manages user session, token storage, bootstrap process
- **ProjectProvider**: Global projects list, search, filtering
- **ProjectDetailProvider**: Per-project state, CRUD operations, real-time updates
- Provider injection via GoRouter parameters for screen-specific state

### API Integration
- Base URL configured via environment variable
- JWT token authentication stored in SharedPreferences
- Automatic token injection via ApiClient
- Error handling with user-friendly messages
- SSL certificate overrides for production API

### Rich Text Editing
- **Flutter Quill** for note content and long descriptions
- Custom editor screen with full formatting capabilities
- Content stored as JSON in database
- Delta-based changes for efficient synchronization

### Design System
- **Primary**: #E07A5F (accentOrange)
- **Secondary**: #F5E6D3 (primaryBeige)
- **Background**: #FFFBF7 (cardBackground)
- **Text**: #2D3436 (darkText)
- Material 3 components with responsive layouts

## Development Guidelines

### Code Organization
- One screen per major feature area in `screens/`
- Shared widgets in `widgets/shared/`
- Screen-specific widgets in `widgets/[feature_name]/`
- Models should be pure data classes with `fromJson`/`toJson`
- Business logic in services layer, not in UI

### State Management Best Practices
- Use `ChangeNotifier` for providers that need to notify listeners
- Separate read-only state from mutable operations
- Dispose providers properly when navigating away
- Use `Consumer` or `Selector` widgets for optimized rebuilds

### API Integration Patterns
- All API calls through repository layer, never directly in UI
- Handle authentication errors gracefully with user feedback
- Show loading states during async operations
- Cache data appropriately in providers

### Testing Strategy
- Widget tests for screen components (existing tests in `test/`)
- Integration tests for provider logic
- Mock API responses for consistent testing

### Common Development Tasks

#### Adding New Entity Type
1. Create model in `models/` with JSON serialization
2. Add repository methods in `repositories/project_repository.dart`
3. Create provider for state management
4. Implement screens for list/detail/edit views
5. Add routes in `router/app_router.dart`
6. Update database schema if needed

#### Modifying Authentication Flow
- Changes primarily in `services/auth_service.dart`
- Update `providers/auth_provider.dart` for state changes
- Adjust router guards in `router/app_router.dart`
- Test session bootstrap flow thoroughly

#### Rich Text Content Changes
- Flutter Quill configuration in `screens/long_description_editor_screen.dart`
- Content serialization in model classes
- Editor toolbar customization for specific use cases

## Production Deployment

### Linux Desktop App
- Use `./tool/package_linux.sh` for Debian packaging
- Outputs to `dist/linux/catatan-kaki_<version>_amd64.deb`
- Version matches `pubspec.yaml` version field
- Requires system dependencies: GTK3, build-essential, etc.

### Environment Configuration
- Production `.env` file excluded from Git
- SSL certificates handled via custom HttpOverrides
- API endpoint should be HTTPS in production
- Consider different API endpoints per environment