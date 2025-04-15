# Design Tokens System

This directory contains the design token system for the Flutter Chart library. The system transforms design tokens from a JSON format into strongly-typed Dart code that can be used throughout the application.

## Overview

Design tokens are the visual design atoms of the design system — specifically, they are named entities that store visual design attributes. These include colors, typography, spacing, and other visual properties that define the look and feel of the UI.

This system uses a set of files to parse, format, and generate Dart code from design tokens:

- `tokens.json`: The source of truth for all design tokens (generated from Figma)
- `design_token_config.json`: Configuration for token categories and output paths
- `design_token_parser.dart`: Main script for parsing tokens and generating code
- `design_token_formatters.dart`: Formatters for different token types (colors, dimensions, etc.)
- `design_token_generators.dart`: Generators for creating Dart classes from tokens
- `design_token_utils.dart`: Utility functions for token processing
- `design_token_logger.dart`: Logging utilities for the token generation process

## Design Patterns

The implementation uses several design patterns:

- **Factory Pattern**: To create appropriate token generators based on token category
- **Strategy Pattern**: To format token values based on their type
- **Template Method Pattern**: Base class defines the algorithm structure, subclasses implement specific steps

## Configuration File

The `design_token_config.json` file defines how tokens are organized and where the generated files are placed:

```json
{
  "tokenCategories": {
    "core": {
      "outputPath": "lib/src/theme/design_tokens/core_design_tokens.dart",
      "className": "CoreDesignTokens",
      "tokenNames": [
        "core/border",
        "core/color/solid",
        "core/color/opacity",
        "core/color/gradients",
        "core/boxShadow",
        "core/opacity",
        "core/spacing",
        "core/typography",
        "core/motion",
        "core/sizing",
        "semantic/global",
        "semantic/viewPort/default"
      ]
    },
    "light": {
      "outputPath": "lib/src/theme/design_tokens/light_theme_design_tokens.dart",
      "className": "LightThemeDesignTokens",
      "tokenNames": [
        "semantic/theme/light"
      ]
    },
    "dark": {
      "outputPath": "lib/src/theme/design_tokens/dark_theme_design_tokens.dart",
      "className": "DarkThemeDesignTokens",
      "tokenNames": [
        "semantic/theme/dark"
      ]
    },
    "component": {
      "outputPath": "lib/src/theme/design_tokens/component_design_tokens.dart",
      "className": "ComponentDesignTokens",
      "tokenNames": [
        "component/component"
      ]
    }
  }
}
```

### Configuration Structure

- **tokenCategories**: Groups tokens into categories (core, light, dark, component)
  - **core**: Tokens shared between light and dark themes (colors, spacing, typography, etc.)
  - **light**: Light theme-specific tokens
  - **dark**: Dark theme-specific tokens
  - **component**: Component-specific tokens with theme variants

For each category:
- **outputPath**: Where to write the generated Dart file
- **className**: The name of the generated Dart class
- **tokenNames**: List of token paths to process from the tokens.json file

## Usage

To generate the design token Dart files:

1. Ensure `tokens.json` is up to date (typically generated from Figma)
2. Run the provided script (recommended):

```bash
bash scripts/generate_and_check_token_files.sh
```

This script:
- Generates the token files
- Formats the generated files
- Auto-fixes common issues
- Analyzes the files for remaining issues
- Runs token parser tests

Alternatively, you can run the parser directly:

```bash
dart lib/src/theme/design_tokens/design_token_parser.dart
```

This will generate four Dart files:
- `core_design_tokens.dart`: Core tokens shared between themes
- `light_theme_design_tokens.dart`: Light theme-specific tokens
- `dark_theme_design_tokens.dart`: Dark theme-specific tokens
- `component_design_tokens.dart`: Component-specific tokens with theme variants

## Token Types

The system supports various token types:

- **Colors**: Hex colors, RGBA colors, and gradients
- **Dimensions**: Spacing, sizing, border radius, etc.
- **Typography**: Font families, sizes, weights, line heights
- **Motion**: Durations and easing curves
- **Shadows**: Box shadows with color, offset, blur, and spread

### Component Tokens

The system supports component-specific tokens (tokens with paths starting with "component" or keys named "component"). These tokens are processed by the ComponentDesignTokenGenerator, which creates:

- Light theme versions of component tokens (with "Light" suffix)
- Dark theme versions of component tokens (with "Dark" suffix)
- Direct references to core tokens when appropriate

Component tokens are generated in the `component_design_tokens.dart` file and can be used to style specific UI components consistently across themes.

## Token Structure in tokens.json

The `tokens.json` file should follow a specific structure for the parser to process it correctly:

```json
{
  "core/color/solid": {
    "red": {
      "500": {
        "value": "#FF0000",
        "type": "color",
        "description": "Primary red color"
      }
    }
  },
  "semantic/theme/light": {
    "background": {
      "primary": {
        "value": "{core.color.solid.slate.50}",
        "type": "color"
      }
    }
  }
}
```

Each token has:
- A hierarchical path (e.g., "core/color/solid/red/500")
- A value (can be a direct value or a reference to another token)
- A type (color, spacing, etc.)
- An optional description

Token references use the format `{path.to.token}` and are automatically resolved during processing.

## Integration with Flutter Applications

To use the generated design tokens in your Flutter application:

1. Import the generated files:

```dart
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/light_theme_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/dark_theme_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/component_design_tokens.dart';
```

2. Use the tokens in your code:

```dart
// Using core tokens
final spacing = CoreDesignTokens.coreSpacing8;
final color = CoreDesignTokens.coreColorSolidRed500;

// Using theme-specific tokens
final lightBackground = LightThemeDesignTokens.backgroundPrimary;
final darkBackground = DarkThemeDesignTokens.backgroundPrimary;

// Using component tokens
final buttonColorLight = ComponentDesignTokens.buttonPrimaryBackgroundLight;
final buttonColorDark = ComponentDesignTokens.buttonPrimaryBackgroundDark;
```

3. Create a theme switcher that uses the appropriate tokens based on the current theme.

## Troubleshooting

### Empty Token Files

If the generated files don't contain any tokens (token count is 0), check:
- The structure of your `tokens.json` file matches the expected format
- The token paths in `design_token_config.json` match the paths in your `tokens.json` file
- There are no syntax errors in your `tokens.json` file

### Missing References

If you see errors about missing token references:
- Ensure all referenced tokens exist in the `tokens.json` file
- Check that the reference syntax is correct (`{path.to.token}`)
- Verify that the referenced token is included in the `tokenNames` list in the configuration

### Import Errors

If you see import errors when using the generated files:
- Ensure the files have been generated successfully
- Check that the import paths are correct
- Run `flutter pub get` to update dependencies

## Extension

To add support for new token types:

1. Add a new formatter in `design_token_formatters.dart`
2. Register the formatter in `TokenFormatterFactory`
3. Update tests in `design_token_parser_test.dart`
