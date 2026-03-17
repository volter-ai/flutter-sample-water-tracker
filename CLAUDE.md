# Flutter Project Guidelines

## Project Overview
This is a simple Flutter clicker application demonstrating basic state management and Material Design principles.

## Code Standards

### Dart Style Guide
- Follow official Dart style guide
- Use `dart format` for consistent formatting
- Prefer const constructors where possible
- Use single quotes for strings
- Avoid print statements in production code

### Flutter Best Practices
- Use StatefulWidget for components with mutable state
- Use StatelessWidget for static components
- Leverage Material Design 3 components
- Follow the widget composition pattern
- Keep widgets small and focused

### File Organization
```
lib/
  main.dart           - Application entry point
  screens/            - Screen-level widgets
  widgets/            - Reusable widget components
  models/             - Data models
  services/           - Business logic and API calls
  utils/              - Helper functions and constants

test/
  widget_test.dart    - Widget tests
  unit/               - Unit tests
  integration/        - Integration tests
```

### State Management
- Use StatefulWidget for simple local state
- Consider Provider, Riverpod, or Bloc for complex state management
- Keep state as close to where it's used as possible

### Testing
- Write widget tests for UI components
- Write unit tests for business logic
- Aim for meaningful test coverage
- Use `flutter test` to run tests

### Dependencies
- Keep dependencies minimal and up to date
- Only add dependencies that provide significant value
- Review dependency licenses for compatibility

### Version Control
- Write clear, descriptive commit messages
- Keep commits focused on single changes
- Use conventional commit format when possible

### Performance
- Use const constructors to reduce rebuilds
- Avoid expensive operations in build methods
- Profile the app regularly with Flutter DevTools
- Optimize images and assets

### Accessibility
- Provide semantic labels for interactive elements
- Ensure sufficient color contrast
- Support screen readers
- Test with TalkBack/VoiceOver

## Development Workflow

1. Run `flutter pub get` after cloning or updating dependencies
2. Use `flutter run` for development
3. Run `flutter analyze` before committing
4. Run `flutter test` to ensure tests pass
5. Use `flutter build` for production builds

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```
