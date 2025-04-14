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
    }
  }
}
```

### Configuration Structure

- **tokenCategories**: Groups tokens into categories (core, light, dark)
  - **core**: Tokens shared between light and dark themes (colors, spacing, typography, etc.)
  - **light**: Light theme-specific tokens
  - **dark**: Dark theme-specific tokens

For each category:
- **outputPath**: Where to write the generated Dart file
- **className**: The name of the generated Dart class
- **tokenNames**: List of token paths to process from the tokens.json file

## Usage

To generate the design token Dart files:

1. Ensure `tokens.json` is up to date (typically generated from Figma)
2. Run the parser script:

```bash
dart lib/src/theme/design_tokens/design_token_parser.dart
```

This will generate three Dart files:
- `core_design_tokens.dart`: Core tokens shared between themes
- `light_theme_design_tokens.dart`: Light theme-specific tokens
- `dark_theme_design_tokens.dart`: Dark theme-specific tokens

## Token Types

The system supports various token types:

- **Colors**: Hex colors, RGBA colors, and gradients
- **Dimensions**: Spacing, sizing, border radius, etc.
- **Typography**: Font families, sizes, weights, line heights
- **Motion**: Durations and easing curves
- **Shadows**: Box shadows with color, offset, blur, and spread

### Limitations

- **Component Tokens**: Component-specific tokens (tokens with paths starting with "component" or keys named "component") are currently not supported and will be skipped during processing. This is a planned feature for future implementation.

## Extension

To add support for new token types:

1. Add a new formatter in `design_token_formatters.dart`
2. Register the formatter in `TokenFormatterFactory`
3. Update tests in `design_token_parser_test.dart`
