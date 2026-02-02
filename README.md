# Hide Actionbar

A simple World of Warcraft addon to toggle actionbar visibility with a keybind or slash command.

## Features

- Toggle visibility of all action bars with a single keybind
- Configure which bars to hide/show
- Adjustable hidden opacity (fully hidden or semi-transparent)
- Settings saved per character

## Installation

1. Download and extract to `World of Warcraft\_retail_\Interface\AddOns\hide_actionbar`
2. Restart WoW or `/reload`

## Usage

### Keybind
Go to **Options → Keybindings → Hide Actionbar** and set your preferred key.

### Slash Commands

| Command | Description |
|---------|-------------|
| `/hab` | Show help |
| `/hab toggle` | Toggle bar visibility |
| `/hab list` | Show all bars and their status |
| `/hab enable <bar>` | Enable a bar for hiding |
| `/hab disable <bar>` | Exclude a bar from hiding |
| `/hab opacity <0-1>` | Set hidden opacity (0 = invisible) |

### Available Bars

- `main` - Main Action Bar
- `bottomleft` - Multi Bar Bottom Left
- `bottomright` - Multi Bar Bottom Right
- `left` - Multi Bar Left
- `right` - Multi Bar Right
- `bar5` - `bar7` - Additional Bars
- `stance` - Stance Bar
- `pet` - Pet Action Bar
- `micro` - Micro Menu
- `bags` - Bags Bar

## License

MIT License - see [LICENSE](LICENSE) for details.
