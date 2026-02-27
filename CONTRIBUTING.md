# Contributing to Piprapay Flutter Package

Thank you for your interest in contributing! We welcome contributions from the community.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/piprapay-flutter.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `flutter test`
6. Submit a pull request

## Before You Start

- Check existing issues and pull requests to avoid duplicates
- Read the [README.md](README.md) and [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- Ensure your code follows Dart conventions
- Write tests for new functionality

## Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments to public APIs
- Run `dart format` before committing: `dart format lib test`
- Run the linter: `flutter analyze`

## Testing

All contributions should include tests.

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models_test.dart

# Run with coverage
flutter test --coverage
```

## Documentation

- Update README.md if you add new features
- Add comments to complex logic
- Update API_DOCUMENTATION.md for API changes
- Provide examples in comments

## Commit Messages

Use clear, descriptive commit messages:

```
feat: Add payment status polling feature
fix: Correct webhook validation error handling
docs: Update API documentation
test: Add tests for refund endpoint
refactor: Simplify error handling logic
```

## Pull Request Process

1. Update documentation and tests
2. Ensure all tests pass locally
3. Add a description of your changes
4. Reference any related issues
5. Request review from maintainers

## Reporting Issues

- Use GitHub Issues to report bugs
- Include reproduction steps
- Provide error messages and logs
- Specify Flutter and Dart versions

## Feature Requests

- Describe the feature and its use case
- Explain why it's needed
- Provide implementation suggestions if possible

## Security

- Never commit API keys or sensitive data
- Report security issues privately to maintainers
- Don't include plaintext credentials in code

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Code of Conduct

Be respectful and professional in all interactions. We're committed to providing a welcoming environment for all contributors.

## Questions?

- Open a discussion on GitHub
- Contact the maintainers
- Check existing documentation

Thank you for contributing to make Piprapay Flutter Package better!
