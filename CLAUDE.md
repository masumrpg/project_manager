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

## Diagram Editor Implementation

The application includes a diagram editor feature built with the **simple_diagram_editor** Flutter library, allowing users to create, edit, and manage diagrams within their projects.

### Flutter Library Integration

**Library**: `simple_diagram_editor` (https://github.com/Arokip/fdl_demo_app)

**Core Data Models**:
- **MyComponentData**: Component visual and text properties
- **MyLinkData**: Connection properties between components

### API Endpoints

#### Diagram Management
```
GET    /api/projects/:projectId/diagrams                    # List all diagrams in project
POST   /api/projects/:projectId/diagrams                    # Create new diagram
GET    /api/projects/:projectId/diagrams/:id                # Get diagram details
PUT    /api/projects/:projectId/diagrams/:id                # Update diagram metadata
DELETE /api/projects/:projectId/diagrams/:id                # Delete diagram (soft delete)
GET    /api/projects/:projectId/diagrams/:id/export         # Export diagram as JSON
POST   /api/projects/:projectId/diagrams/:id/duplicate      # Duplicate diagram
```

#### Component Operations
```
GET    /api/projects/:projectId/diagrams/:id/components     # List all components
POST   /api/projects/:projectId/diagrams/:id/components     # Add component to diagram
PUT    /api/projects/:projectId/diagrams/:id/components/:cid # Update component
DELETE /api/projects/:projectId/diagrams/:id/components/:cid # Delete component
```

#### Link Operations
```
GET    /api/projects/:projectId/diagrams/:id/links          # List all links
POST   /api/projects/:projectId/diagrams/:id/links          # Add link between components
PUT    /api/projects/:projectId/diagrams/:id/links/:lid     # Update link
DELETE /api/projects/:projectId/diagrams/:id/links/:lid     # Delete link
```

#### Version Control
```
GET    /api/projects/:projectId/diagrams/:id/versions       # Get version history
POST   /api/projects/:projectId/diagrams/:id/versions       # Create version snapshot
GET    /api/projects/:projectId/diagrams/:id/versions/:versionId # Get specific version
POST   /api/projects/:projectId/diagrams/:id/restore/:versionId # Restore to specific version
```

### Flutter Data Models

#### Component Model (Based on Flutter Library)
```dart
class ComponentData {
  Color color;           // Fill color
  Color borderColor;     // Border color
  double borderWidth;    // Border width
  String text;           // Text content
  Alignment textAlignment; // Text alignment
  double textSize;       // Font size
  bool isHighlightVisible; // Selection state

  // Additional properties for position and size managed by editor
  double x, y;           // Position
  double width, height;  // Size
  String shapeType;      // rectangle, circle, text, etc.
  int zIndex;            // Layer ordering
}
```

#### Link Model (Based on Flutter Library)
```dart
class LinkData {
  String startLabel;     // Label near start point
  String endLabel;       // Label near end point

  // Additional properties for connection management
  String componentIdStart; // Source component ID
  String componentIdEnd;   // Target component ID
  Color color;            // Line color
  double width;           // Line thickness
  String style;           // solid, dashed, dotted
  bool showStartArrow;    // Arrow at start
  bool showEndArrow;      // Arrow at end
}
```

### Implementation Architecture

#### Directory Structure
```
lib/
├── models/
│   ├── diagram.dart        # Diagram entity
│   ├── component_data.dart # Component data model
│   └── link_data.dart      # Link data model
├── providers/
│   └── diagram_provider.dart # Diagram state management
├── repositories/
│   └── diagram_repository.dart # Diagram API abstraction
├── screens/
│   └── diagram_editor_screen.dart # Main diagram editor UI
├── widgets/
│   └── diagram_editor/     # Diagram-specific widgets
│       ├── diagram_canvas.dart
│       ├── component_widget.dart
│       └── link_widget.dart
└── services/
    └── diagram_service.dart # Diagram business logic
```

#### State Management
- **DiagramProvider**: Manages diagram state, components, and links
- Real-time updates with WebSocket support
- Undo/redo functionality
- Selection and highlighting management
- Component and link data synchronization with API

#### UI Components
- **DiagramCanvas**: Main drawing area from simple_diagram_editor
- **ComponentWidget**: Visual representation using MyComponentData
- **LinkWidget**: Connection representation using MyLinkData
- **PropertyPanel**: Component/link property editor
- **Toolbar**: Diagram editing tools and shapes

### Features

#### Core Functionality
- Drag-and-drop component positioning
- Component selection and multi-selection with `isHighlightVisible`
- Link creation between components
- Component property editing (color, text, borders)
- Text editing within components with configurable alignment
- Component highlighting and visual feedback

#### Advanced Features
- Version control with snapshots
- Diagram export/import (JSON format)
- Collaborative editing (WebSocket)
- Zoom and pan controls
- Grid snapping
- Keyboard shortcuts
- Context menus

#### Data Synchronization
- Real-time component updates to API
- Efficient batch updates for performance
- Conflict resolution for collaborative editing
- Local caching for offline capability

### Integration with Existing Architecture

#### Provider Integration
- DiagramProvider integrates with existing ProjectDetailProvider
- Shares authentication via AuthProvider
- Uses same ApiClient for consistent HTTP handling

#### Navigation Integration
- Added to GoRouter configuration
- Accessible from ProjectDetailScreen
- Maintains existing navigation patterns

#### API Integration
- Follows existing repository pattern
- Consistent error handling with other features
- Same authentication token management