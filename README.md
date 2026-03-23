# arrange_displays

A lightweight macOS CLI tool to quickly arrange external displays relative to your internal display.

## Installation

Download the latest release:

```bash
# Download and install (Apple Silicon only)
curl -L -o /usr/local/bin/arrange_displays https://github.com/abdusco/arrange-displays/releases/latest/download/arrange_displays-arm64
chmod +x /usr/local/bin/arrange_displays
```

## Usage

```bash
arrange_displays <position>
```

### Positions

- `top` - Place external display above internal display
- `bottom` - Place external display below internal display
- `left` - Place external display to the left of internal display
- `right` - Place external display to the right of internal display

### Examples

```bash
# Place external display on top
arrange_displays top

# Place external display to the right
arrange_displays right

# Show help
arrange_displays --help
```

## Building from Source

Requires macOS with Swift toolchain installed:

```bash
./build.sh
```

This creates an `arrange_displays` executable in the current directory.

## Requirements

- macOS 11.0 or later
- At least two displays connected

## License

MIT
