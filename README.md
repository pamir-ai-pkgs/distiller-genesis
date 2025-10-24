# distiller-genesis

Genesis meta-package for the Distiller CM5 platform.

## Overview

This meta-package provides a convenient way to install various components for the Distiller CM5 platform. As a true meta-package, it primarily pulls in recommended dependencies without forcing their installation.

The package can be used to install random stuff as needed - dependencies can be added to the Recommends or Suggests fields in debian/control.

## Package Structure

```
debian/
├── control              # Package metadata and dependencies
├── copyright            # License information
├── rules                # Build rules (makefile)
├── changelog            # Version history
├── compat               # Debhelper compatibility level
├── gbp.conf             # git-buildpackage configuration
├── preinst              # Pre-installation script
├── postinst             # Post-installation script
├── prerm                # Pre-removal script
├── postrm               # Post-removal script
├── distiller-genesis.lintian-overrides  # Lintian override rules
├── distiller-genesis.install        # File installation rules
└── source/
    └── format           # Source package format
```

## Building the Package

### Prerequisites

```bash
sudo apt-get install debhelper git-buildpackage lintian
```

### Build Commands

```bash
# Build binary package
dpkg-buildpackage -us -uc -b

# Build with git-buildpackage
gbp buildpackage

# Check with lintian
lintian -I --show-overrides ../distiller-genesis_*.deb
```

## Installation

```bash
sudo dpkg -i distiller-genesis_1.0.0_all.deb
sudo apt-get install -f  # Install recommended dependencies
```

## What Gets Installed

This meta-package recommends the following (not forced):

- **distiller-cm5-sdk**: Hardware control and AI SDK
- **Python 3**: Runtime environment and pip
- **Development tools**: Build essentials, git

Recommended packages can be installed independently or skipped as needed.

## Adding Dependencies

To add more packages to be installed:

1. Edit `debian/control`
2. Add to `Recommends:` for suggested installations
3. Add to `Suggests:` for optional installations
4. Rebuild the package

## Maintainer Scripts

All maintainer scripts are minimal for a meta-package:

- **preinst**: No operations (placeholder)
- **postinst**: Simple notification message
- **prerm**: No operations (placeholder)
- **postrm**: Simple removal notification

Removing this package will NOT remove installed dependencies.

## Development

### Updating the Package

1. Edit files in `debian/` as needed
2. Update `debian/changelog` with new version
3. Rebuild the package
4. Test installation/upgrade/removal

### Version Management

```bash
# Update changelog for new version
dch -i

# Commit changes
git add debian/
git commit -m "Update meta-distiller to version X.Y.Z"

# Tag release
git tag -a vX.Y.Z -m "Release X.Y.Z"
```

## License

MIT License - See debian/copyright for full text
