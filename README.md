# distiller-genesis

Meta-package for complete Distiller platform installation on ARM64 hardware (Raspberry Pi CM5, Radxa Zero 3/3W, ArmSom CM5 IO).

## Overview

`distiller-genesis` is a **Debian meta-package** that simplifies installation of the complete Distiller software stack. It contains no executable code - only dependency declarations that automatically pull in all required packages for a working Distiller system.

**Key Features**:
- Single-command installation of entire Distiller platform
- Platform-specific variants for optimized hardware support
- Flexible package management (remove/reinstall components individually)
- Uses recommendations rather than hard dependencies for user control
- Hierarchical package structure for common + platform-specific components

## Package Variants

Three packages are available to match your hardware platform:

| Package | Target Hardware | Additional Drivers |
|---------|----------------|-------------------|
| `distiller-genesis-cm5` | Raspberry Pi CM5 (BCM2712) | TLV320AIC3204 audio codec |
| `distiller-genesis-rockchip` | Radxa Zero 3/3W (RK3566)<br>ArmSom CM5 IO (RK3576) | None (uses common drivers) |
| `distiller-genesis-common` | Base stack (all platforms) | Universal components only |

**Platform Selection Guide**:
- **Raspberry Pi CM5**: Install `distiller-genesis-cm5`
- **Radxa Zero 3/3W or ArmSom CM5 IO**: Install `distiller-genesis-rockchip`
- **Custom/Development**: Install `distiller-genesis-common` + manually select drivers

## Package Hierarchy

```
distiller-genesis-cm5 (or distiller-genesis-rockchip)
    │
    ├── distiller-genesis-common
    │   ├── distiller-sdk              # Hardware SDK (Audio, Camera, E-ink, ASR/TTS)
    │   ├── distiller-services         # WiFi provisioning service
    │   ├── distiller-update           # APT update notifications
    │   ├── distiller-telemetry        # Device registration
    │   ├── distiller-cc               # Claude Code extensions
    │   ├── claude-code-web-manager    # Web-based Claude Code UI
    │   ├── pamir-ai-sam-dkms          # SAM controller kernel driver
    │   ├── distiller-migrator         # Migration tool
    │   └── distiller-test-harness     # Test suite
    │
    └── pamir-ai-soundcard-dkms (CM5 only)
```

## Installation

### Prerequisites

```bash
# Update package index
sudo apt-get update

# Ensure APT can handle dependencies
sudo apt-get install -f
```

### Install from Package Repository

**For Raspberry Pi CM5**:
```bash
sudo apt-get install distiller-genesis-cm5
```

**For Radxa Zero 3/3W or ArmSom CM5 IO**:
```bash
sudo apt-get install distiller-genesis-rockchip
```

## What Gets Installed

### Core Components (All Platforms)

| Package | Description | Installation Path |
|---------|-------------|-------------------|
| **distiller-sdk** | Hardware SDK with ASR/TTS, audio, camera, e-ink support | `/opt/distiller-sdk/` |
| **distiller-services** | WiFi provisioning with mDNS and captive portal | `/opt/distiller-services/` |
| **distiller-telemetry** | Device registration using MAC-based tokens | `/opt/distiller-telemetry/` |
| **distiller-update** | APT update checker with DBus notifications | `/opt/distiller-update/` |
| **distiller-cc** | Claude Code extensions (agents, commands, docs) | `~/.claude/` |
| **claude-code-web-manager** | Web UI for Claude Code sessions | `/opt/claude-code-web-manager/` |
| **pamir-ai-sam-dkms** | SAM controller kernel driver | Kernel modules |
| **distiller-migrator** | Database and configuration migration tool | `/opt/distiller-migrator/` |
| **distiller-test-harness** | pytest-based test suite (66+ tests) | `/opt/distiller-test-harness/` |

### Platform-Specific Components

**Raspberry Pi CM5 Only**:
- `pamir-ai-soundcard-dkms`: TLV320AIC3204 audio codec driver (BCM2712-specific)

## Build from Source

### Build Requirements

```bash
sudo apt-get install build-essential debhelper debhelper-compat just
```

### Build Process

```bash
# Clone repository
git clone https://github.com/pamir-ai-pkgs/distiller-genesis.git
cd distiller-genesis

# Build all three packages
just build

# Output: dist/*.deb
# - distiller-genesis-common_<version>_all.deb
# - distiller-genesis-cm5_<version>_all.deb
# - distiller-genesis-rockchip_<version>_all.deb
```

### Justfile Commands

```bash
just --list          # Show available commands
just clean           # Remove build artifacts
just build           # Build all three .deb packages (arch=all)
just changelog       # Update version (dch -i)
```

### Install Locally Built Package

```bash
# Install platform-specific variant
sudo dpkg -i dist/distiller-genesis-cm5_*.deb        # For CM5
sudo dpkg -i dist/distiller-genesis-rockchip_*.deb   # For Rockchip

# Resolve dependencies
sudo apt-get install -f
```

## Customizing Your Installation

The meta-package uses recommendations (`Recommends:`) to allow flexible package management:

### Removing Individual Components

```bash
# Remove a specific service
sudo apt remove distiller-services

# Meta-package stays installed
dpkg -l | grep distiller-genesis
```

### Restoring Removed Components

```bash
# Reinstall meta-package to restore missing components
sudo apt install --reinstall distiller-genesis-cm5

# APT automatically reinstalls recommended packages
```

### Minimal Installation

```bash
# Install only meta-package without components (rare use case)
sudo apt install --no-install-recommends distiller-genesis-cm5

# Manually install only desired components
sudo apt install distiller-sdk distiller-services
```

## Development

This meta-package is part of the Google Repo-managed Distiller ecosystem. For development workflows:

```bash
# Initialize multi-repository workspace
repo init -u https://github.com/pamir-ai-pkgs/manifest.git
repo sync

# Make changes to individual packages
cd ../distiller-sdk
just build && sudo dpkg -i dist/*.deb

# Update meta-package dependencies (in distiller-genesis/)
cd ../distiller-genesis
vim debian/control               # Edit Depends: field
just changelog                   # Update version
just build                       # Rebuild meta-package
```

See [parent CLAUDE.md](../CLAUDE.md) for complete multi-repository development guide.

## Version Management

```bash
# Update changelog and version
just changelog                   # Interactive (dch -i)

# Manual version update
dch -v 1.1.0                     # Set specific version
dch -a "Added new-package to dependencies"  # Add entry

# Check current version
dpkg-parsechangelog --show-field Version
```

## License

MIT License - Copyright 2025 PamirAI Incorporated

See [debian/copyright](debian/copyright) for full license text.

## Support

- **Issues**: [GitHub Issues](https://github.com/pamir-ai-pkgs/distiller-genesis/issues)
- **Email**: support@pamir.ai
