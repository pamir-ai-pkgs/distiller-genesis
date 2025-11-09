# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**distiller-genesis** is a Debian meta-package that simplifies installation of the complete Distiller platform. It contains no executable code - only dependency declarations.

**Three Package Variants**:
- `distiller-genesis-common`: Base stack for all platforms (SDK, services, drivers)
- `distiller-genesis-cm5`: Raspberry Pi CM5 specific (depends on common + recommends TLV320AIC3204 audio driver)
- `distiller-genesis-rockchip`: Rockchip platforms (Radxa Zero 3/3W, ArmSom CM5 IO, depends on common only)

**Package Hierarchy**:
```
distiller-genesis-cm5 (or distiller-genesis-rockchip)
    └── Depends: distiller-genesis-common (exact version match)
            ├── distiller-sdk (>= 3.0.0)         # Hardware SDK [Recommends]
            ├── distiller-services (>= 3.0.0)    # WiFi provisioning [Recommends]
            ├── distiller-update (>= 3.0.0)      # APT notifications [Recommends]
            ├── distiller-telemetry (>= 4.0.0)   # Device registration [Recommends]
            ├── distiller-cc (>= 5.0.0)          # Claude Code extensions [Recommends]
            ├── claude-code-web-manager          # Web UI [Recommends]
            ├── pamir-ai-sam-dkms                # SAM controller driver [Recommends]
            └── distiller-platform-update        # System updater [Recommends]
```

## Build Commands

```bash
# Build all three packages
just build                    # Creates .deb files in dist/

# Version management
just changelog                # Update changelog (gbp dch -R)

# Clean build artifacts
just clean                    # Remove debian/ build artifacts and dist/
```

**Build Output**:
- `dist/distiller-genesis-common_<version>_all.deb`
- `dist/distiller-genesis-cm5_<version>_all.deb`
- `dist/distiller-genesis-rockchip_<version>_all.deb`

All packages are architecture-independent (`Architecture: all`) since they only declare dependencies.

## Version Management

Uses `gbp dch` (git-buildpackage) for changelog management:

```bash
# Update version and release
just changelog                # Runs: gbp dch -R --ignore-branch --release

# Manual changelog editing
dch -v 1.1.0                  # Set specific version
dch -a "Added new dependency" # Add changelog entry

# Check current version
dpkg-parsechangelog --show-field Version
```

**Version Scheme**: `<major>.<minor>.<patch>` (e.g., `1.0.2`)

## Testing Changes

```bash
# After modifying debian/control dependencies:

# 1. Build packages
just build

# 2. Test installation locally (on appropriate hardware)
sudo dpkg -i dist/distiller-genesis-cm5_*.deb        # For CM5
sudo dpkg -i dist/distiller-genesis-rockchip_*.deb   # For Rockchip

# 3. Resolve dependencies (APT auto-installs recommended packages)
sudo apt-get install -f

# 4. Verify all components installed
dpkg -l | grep -E "distiller|pamir-ai"

# 5. Test removal flexibility (should not remove meta-package)
sudo apt remove distiller-services
dpkg -l | grep distiller-genesis  # Should still show installed

# 6. Test reinstall restores components
sudo apt install --reinstall distiller-genesis-cm5
dpkg -l | grep distiller-services  # Should show reinstalled
```

## Architecture Notes

### Meta-Package Pattern

**Two-tier dependency structure**:
- Platform packages (cm5/rockchip) **hard-depend** on `distiller-genesis-common`
- Common package **recommends** individual components for flexibility

**Why this structure?**
- Ensures platform packages always install the common base (Depends)
- Users can still remove individual components from common package (Recommends)
- Prevents version mismatches between platform and common packages
- `apt install --reinstall` restores missing recommended components
- Allows minimal installs with `--no-install-recommends` for debugging

### Package Relationships

**Platform-specific packages** (cm5/rockchip) **depend** on `distiller-genesis-common`:
```debcontrol
Package: distiller-genesis-cm5
Depends: ${misc:Depends},
         distiller-genesis-common (= ${binary:Version})
Recommends: pamir-ai-soundcard-dkms
```

**Common package** recommends all base components:
```debcontrol
Package: distiller-genesis-common
Recommends: distiller-sdk (>= 3.0.0),
            distiller-services (>= 3.0.0),
            distiller-cc (>= 5.0.0),
            ...
```

**Version Pinning**: Platform packages **depend** on exact version of `distiller-genesis-common` (`= ${binary:Version}`) to ensure all three packages stay in sync.

## Migration from Old Packages

This package replaces legacy packages from earlier Distiller versions.

**Automatic Migration**: When installing `distiller-genesis-common`, APT will automatically:
- Remove `distiller-cm5-sdk` and `distiller-cm5-services` (obsolete)
- Remove conflicting kernel headers (`linux-headers-6.1.0-40-arm64`, `linux-headers-arm64`)
- Install new unified packages

**Conflicts/Replaces Fields** (debian/control:15-20):
```debcontrol
Conflicts: distiller-cm5-sdk,
           distiller-cm5-services,
           linux-headers-6.1.0-40-arm64,
           linux-headers-arm64
Replaces: distiller-cm5-sdk,
          distiller-cm5-services
```

**Manual Migration** (if needed):
```bash
# Remove old packages before installing new ones
sudo apt remove distiller-cm5-sdk distiller-cm5-services
sudo apt install distiller-genesis-cm5
```

## Modifying Dependencies

When adding/removing packages to the Distiller platform:

```bash
# 1. Edit debian/control
vim debian/control

# Add new package to Recommends: field of distiller-genesis-common
# Format: package-name (>= min-version),

# 2. Update changelog
just changelog

# 3. Build and test
just build
sudo dpkg -i dist/distiller-genesis-common_*.deb
sudo apt-get install -f  # Installs new recommended package
```

**Dependency Guidelines**:
- **Common package Recommends**: Add SDK, services, drivers used by all platforms
- **Platform package Recommends**: Add hardware-specific drivers (e.g., `pamir-ai-soundcard-dkms` for CM5)
- **Suggests**: Optional development/testing tools (`distiller-test-harness`)
- **Version constraints**: Use `>= X.Y.Z` for minimum versions
  - Currently: SDK/services/update >= 3.0.0, telemetry >= 4.0.0, cc >= 5.0.0
- **Platform-specific drivers**: Add to cm5/rockchip package Recommends, NOT common package

## Build System Details

**Justfile uses debuild**:
```bash
debuild -us -uc -b -aall -d --lintian-opts --profile=debian
```

Flags:
- `-us -uc`: Don't sign package
- `-b`: Binary-only build (no source package)
- `-aall`: Architecture-independent (meta-packages work on any architecture)
- `-d`: Don't check build dependencies (meta-package has none)
- `--lintian-opts --profile=debian`: Run lintian checks

**Note**: Default architecture is `all` (not `arm64`) since meta-packages only declare dependencies, they work on any architecture.

**Lintian Overrides**: Each package has overrides in `debian/<package>.lintian-overrides` to suppress expected warnings for meta-packages (empty-binary-package, etc.).

## Common Workflows

### Adding a New Platform Variant

```bash
# 1. Edit debian/control
vim debian/control

# Add new package stanza:
Package: distiller-genesis-<platform>
Architecture: all
Depends: ${misc:Depends},
         distiller-genesis-common (= ${binary:Version})
Recommends: <platform-specific-driver>
Description: Complete Distiller stack for <Platform Name>
 ...

# 2. Create lintian overrides
vim debian/distiller-genesis-<platform>.lintian-overrides

# 3. Update Justfile clean target
vim Justfile  # Add new package to clean recipe

# 4. Build and test
just build
```

### Updating Minimum Versions

When dependent packages release breaking changes:

```bash
# 1. Update version constraints in debian/control
vim debian/control

# Change: distiller-sdk (>= 3.0.0)
# To: distiller-sdk (>= 4.0.0)

# 2. Document in changelog
just changelog
# Add entry: "Bump distiller-sdk minimum version to 4.0.0 (required for feature X)"

# 3. Build and verify
just build
```
