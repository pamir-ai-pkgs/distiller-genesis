# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`distiller-genesis` is a **meta-package** repository that provides convenient installation of the complete Distiller software stack via Debian package dependencies. It contains no executable code - only Debian packaging metadata that declares dependencies on other Distiller packages.

**Repository Type**: Debian meta-package (dependency aggregator)
**Purpose**: Simplified installation of Distiller platform via single package
**Target Platform**: ARM64 Linux (Raspberry Pi CM5, Radxa Zero 3/3W, ArmSom CM5 IO)
**Package Manager**: Google Repo (part of multi-repository ecosystem at `/home/utsav/dev/pamir-ai/`)

## Architecture

### Meta-Package Structure

This repository builds **three Debian packages** with a hierarchical dependency structure:

```
distiller-genesis-cm5           # Raspberry Pi CM5 complete stack
    └── distiller-genesis-common + pamir-ai-soundcard-dkms

distiller-genesis-rockchip      # Rockchip complete stack (Radxa Zero 3/3W, ArmSom CM5 IO)
    └── distiller-genesis-common

distiller-genesis-common        # Base stack (all platforms)
    ├── distiller-sdk           # Hardware SDK (>= 3.0.0) [Recommends]
    ├── distiller-services      # WiFi provisioning (>= 3.0.0) [Recommends]
    ├── distiller-update        # APT update checker (>= 3.0.0) [Recommends]
    ├── distiller-telemetry     # Device registration (>= 4.0.0) [Recommends]
    ├── distiller-cc            # Claude Code extensions (>= 4.0.0) [Recommends]
    ├── claude-code-web-manager # Web-based Claude Code UI [Recommends]
    ├── pamir-ai-sam-dkms       # SAM controller driver [Recommends]
    ├── distiller-platform-update # System configuration updater [Recommends]
    └── distiller-test-harness  # Test suite [Suggests]
```

**Platform-Specific Drivers**:
- **CM5**: Includes `pamir-ai-soundcard-dkms` (TLV320AIC3204 audio codec, BCM2712 only) [Recommends]
- **Rockchip**: No additional drivers (uses common stack only)

**Dependency Types**:
- `[Recommends]`: Installed by default, can be removed individually without cascade
- `[Suggests]`: Optional recommendation (not installed by default)

### Repository Structure

```
distiller-genesis/
├── debian/
│   ├── control                          # Package metadata and dependencies
│   ├── changelog                        # Version history
│   ├── rules                            # Build rules (minimal, uses dh)
│   ├── gbp.conf                         # git-buildpackage configuration
│   ├── copyright                        # MIT license
│   ├── distiller-genesis-common.install # Empty (meta-package)
│   ├── distiller-genesis-cm5.install    # Empty (meta-package)
│   ├── distiller-genesis-rockchip.install # Empty (meta-package)
│   └── *.lintian-overrides              # Suppress empty-binary-package warnings
├── Justfile                             # Build automation (preferred interface)
├── .gitignore                           # Debian build artifacts
└── README.md                            # User-facing documentation
```

**Key Files**:
- `debian/control`: Defines all three packages and their dependency trees
  - Uses `debhelper-compat (= 13)` in Build-Depends (no separate compat file needed)
  - Common package dependencies: debian/control:14-23 (Depends + Suggests)
  - CM5 package dependencies: debian/control:38-39
  - Rockchip package dependencies: debian/control:52
- `debian/changelog`: Maintained via `dch` command for version management
- `debian/gbp.conf`: Configures git-buildpackage for release automation
- `Justfile`: Build automation (runs debuild with optimized flags, parallel builds)
- `debian/*.lintian-overrides`: Suppresses `empty-binary-package` warnings (meta-packages contain no files)

## Build Commands

### Quick Reference

```bash
just --list                  # Show all available commands
just build                   # Build all three packages (recommended)
just clean                   # Clean build artifacts
just changelog               # Update version (dch -i)
```

### Standard Build Process (Using Justfile)

```bash
# Build all three packages (preferred method)
just build                   # Outputs to dist/*.deb
just build arch=all          # Explicit architecture (default)

# Clean build artifacts
just clean
```

Output: Three `.deb` files in `dist/` directory:
- `distiller-genesis-common_<version>_all.deb`
- `distiller-genesis-cm5_<version>_all.deb`
- `distiller-genesis-rockchip_<version>_all.deb`

**Note**: All packages are architecture-independent (`Architecture: all` in debian/control). The Justfile uses parallel builds (`parallel=$(nproc)`) and runs lintian checks automatically.

**Build Process Details**:
1. `debuild` reads `debian/control` and identifies three binary packages
2. All three packages are built simultaneously (single `debuild` invocation)
3. Each package gets its own `.install` file (all empty for meta-packages)
4. Lintian checks run automatically with `--profile=debian`
5. Outputs are moved to `dist/` directory for easier access

### Alternative: Direct debuild Usage

```bash
# Build all three packages
debuild -us -uc              # Build without signing
debuild -b -us -uc           # Build binary packages only (faster)

# Build and sign (for releases)
debuild                      # Build and sign with GPG key
```

Output: `.deb` files in parent directory (`../`)

### Version Management

```bash
# Set author information (required for changelog entries)
export DEBFULLNAME="PamirAI Incorporated"
export DEBEMAIL="founders@pamir.ai"

# Update changelog and increment version
dch -i                       # Interactive changelog entry (increments version)
dch -v 1.1.0                 # Set specific version
dch -a "Description"         # Add entry to current version

# View current version
dpkg-parsechangelog --show-field Version

# Alternative: Use just command with environment variables
DEBFULLNAME="PamirAI Incorporated" DEBEMAIL="founders@pamir.ai" just changelog
```

**Version Format**: `<major>.<minor>.<patch>` (e.g., `1.0.0`)

**Important**: All three packages (common, cm5, rockchip) share the same version number from `debian/changelog`. They are built together in a single `debuild` invocation.

### Installation Testing

```bash
# Install meta-package (pulls all dependencies)
sudo dpkg -i dist/distiller-genesis-cm5_*.deb      # For Raspberry Pi CM5
sudo dpkg -i dist/distiller-genesis-rockchip_*.deb # For Rockchip platforms

# Handle missing dependencies
sudo apt-get install -f      # Resolve dependency issues

# Verify installation
dpkg -l | grep -E "distiller|pamir-ai"
dpkg -s distiller-genesis-cm5 | grep -E "Status|Version"
```

## Development Workflow

### Modifying Dependencies

When adding/removing packages from the Distiller stack:

1. **Edit `debian/control`** to update `Depends:` field (debian/control:14-23 for common, 38-39 for CM5, 52 for Rockchip)
2. **Update changelog**: `just changelog` (or `dch -a "Added package-name to dependencies"`)
3. **Build and test**: `just build`
4. **Verify dependency resolution**: `sudo dpkg -i dist/distiller-genesis-*.deb && apt-get install -f`

**Dependency Format** (debian/control):
```
Depends: ${misc:Depends}
Recommends: package-name,
            another-package (>= version)
Suggests: optional-package (>= version)
```

**Important**:
- `Depends:` contains only `${misc:Depends}` (required by Debian policy)
- `Recommends:` are installed by default but removable without cascade
- `Suggests:` are optional recommendations (not installed by default)

### Package Flexibility

The meta-package uses `Recommends:` instead of hard dependencies to allow flexible package management:

**Removing components:**
```bash
sudo apt remove distiller-services
# Result: Only distiller-services removed, meta-package stays installed
```

**Restoring components:**
```bash
sudo apt install --reinstall distiller-genesis-cm5
# APT reinstalls any missing recommended packages
```

**Edge case (explicit opt-out):**
```bash
sudo apt install --no-install-recommends distiller-genesis-cm5
# Installs only meta-packages, no components (rare, intentional)
```

### Adding Platform-Specific Packages

To add drivers/services for specific hardware:

- **CM5-only**: Add to `distiller-genesis-cm5` package `Depends:` (debian/control:38-39)
- **Rockchip-only**: Add to `distiller-genesis-rockchip` package `Depends:` (debian/control:52)
- **Universal**: Add to `distiller-genesis-common` package `Depends:` (debian/control:14-23)

### Release Process

```bash
# 1. Update version
just changelog               # Interactive version update (dch -i)
# OR
dch -v 1.1.0                # Set specific version

# 2. Build packages
just build

# 3. Tag release
git tag -a v1.1.0 -m "Release 1.1.0"
git push origin v1.1.0

# 4. Upload to repository
# (Repository-specific commands - typically dput or aptly)
```

## Package Relationships

### Dependency Chain

```
User Installation
    ↓
distiller-genesis-{cm5,rockchip}  ← Entry point (this repository)
    ↓
distiller-genesis-common
    ↓
├── distiller-sdk               ← Core SDK (MUST install first in development)
├── distiller-services          ← Depends on SDK
├── distiller-telemetry         ← Depends on SDK
├── distiller-test-harness      ← Depends on SDK
├── distiller-update            ← Standalone
├── distiller-cc                ← Standalone
├── claude-code-web-manager     ← Standalone
├── pamir-ai-sam-dkms           ← Standalone kernel driver
└── distiller-migrator          ← Standalone tool
```

### Platform Detection

Meta-packages are platform-agnostic (`Architecture: all`). Platform-specific behavior is handled by:
- **Dependency selection**: Install `distiller-genesis-cm5` OR `distiller-genesis-rockchip`
- **Runtime detection**: Individual packages (SDK, services) use `/opt/distiller-sdk/platform-detect.sh`

## Integration with Multi-Repository Workflow

This repository is part of the Google Repo-managed ecosystem at `/home/utsav/dev/pamir-ai/`. See parent CLAUDE.md for:
- Repository synchronization (`repo sync`)
- Cross-repository development workflows
- SDK dependency management
- Testing across packages

**Key Constraint**: When testing meta-package installation, ensure dependent packages (SDK, services, etc.) are built and available in APT repository or local filesystem.

## Lintian Overrides

All three packages suppress `empty-binary-package` warning (debian/*.lintian-overrides) because meta-packages intentionally contain no files - they exist solely to declare dependencies.

Files:
- `debian/distiller-genesis-common.lintian-overrides`
- `debian/distiller-genesis-cm5.lintian-overrides`
- `debian/distiller-genesis-rockchip.lintian-overrides`

## Troubleshooting

### Dependency Resolution Failures

```bash
# Check which dependencies are missing
apt-cache policy distiller-sdk distiller-services distiller-telemetry

# Install individual packages manually if APT repository is not configured
sudo dpkg -i /path/to/distiller-sdk_*.deb
sudo dpkg -i /path/to/distiller-services_*.deb
# ... etc

# Then install meta-package
sudo dpkg -i dist/distiller-genesis-cm5_*.deb
sudo apt-get install -f  # Resolve remaining dependencies
```

### Version Conflicts

```bash
# Check installed versions
dpkg -l | grep -E "distiller|pamir-ai"

# Meta-package requires exact version match for distiller-genesis-common
# distiller-genesis-cm5 Depends: distiller-genesis-common (= ${binary:Version})
# All three packages MUST have same version number

# If versions mismatch, rebuild all packages together
just build  # Builds all three with matching versions
```

### Build Failures

```bash
# Missing debhelper-compat
sudo apt-get install debhelper

# Check debhelper version
dpkg -l debhelper  # Must be >= 13

# Missing just
sudo apt-get install just
# OR install from cargo: cargo install just
```

## Git-Buildpackage Configuration

Configured for automated release workflows (debian/gbp.conf):
- **Upstream tags**: `v<version>` (e.g., `v1.0.0`)
- **Debian branch**: `main`
- **Changelog author**: Automatically uses PamirAI Incorporated metadata
- **Log format**: No merge commits, no decorations
