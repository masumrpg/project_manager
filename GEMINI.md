# Project Overview

This is a Flutter-based project management application designed to help users manage projects, notes, revisions, and tasks through a modern and intuitive interface. The application supports multiple platforms including Android, iOS, Web, Windows, macOS, and Linux.

## Main Technologies

*   **Frontend:** Flutter
*   **State Management:** Provider
*   **Local Storage:** Hive (NoSQL)
*   **Rich Text Editing:** Flutter Quill
*   **API Client:** `http` package
*   **Authentication:** JWT-based authentication with a backend API.

## Architecture

The application follows a layered architecture:

*   **UI Layer:** Comprises screens and widgets.
*   **Provider Layer:** Manages the application's state using the `provider` package.
*   **Repository Layer:** Abstracts data sources and provides a clean API for data access to the UI layer.
*   **Service Layer:** Contains business logic and interacts with the backend API through an `ApiClient`.
*   **Data Layer:** Consists of data models and local storage (Hive).

# Building and Running

## Prerequisites

*   Flutter SDK (>=3.9.2)
*   Dart SDK
*   Android Studio / VS Code
*   Git

## Local Development

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd project_manager
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

## Building for Production

*   **Android:**
    ```bash
    flutter build apk --release
    ```
    or
    ```bash
    flutter build appbundle --release
    ```

*   **iOS:**
    ```bash
    flutter build ios --release
    ```

*   **Web:**
    ```bash
    flutter build web
    ```

*   **Desktop (Windows, macOS, Linux):**
    ```bash
    flutter build <platform>
    ```
    (replace `<platform>` with `windows`, `macos`, or `linux`)

# Development Conventions

## Coding Style

The project follows the recommended lints from the `flutter_lints` package, as defined in `analysis_options.yaml`. Key conventions include:

*   Prefer using `const` where possible.
*   Avoid using `print()` in production code; use a proper logger instead.
*   Follow Dart's naming conventions (e.g., `camelCase` for variables and functions, `PascalCase` for classes).

## Testing

The project has a `test` directory, but it currently only contains a default widget test.

**TODO:** Add more comprehensive unit, widget, and integration tests.

## API Interaction

All interactions with the backend API are handled by the `ApiClient` class (`lib/services/api_client.dart`). The API endpoints are documented in the Postman collection at `api/reference/Project Manager API.postman_collection.json`.

The base URL for the API is configured in `lib/main.dart`.

## State Management

The application uses the `provider` package for state management. Key providers include:

*   `AuthProvider`: Manages user authentication state.
*   `ProjectProvider`: Manages project-related data.

Providers are registered in `lib/main.dart`.
