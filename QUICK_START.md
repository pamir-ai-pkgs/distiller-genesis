# distiller-genesis Quick Start

## Build the Package

```bash
dpkg-buildpackage -us -uc -b
```

## Install the Package

```bash
sudo dpkg -i ../distiller-genesis_1.0.0_all.deb
```

## Add New Dependencies

Edit `debian/control`, add to Recommends section:

```
Recommends: distiller-cm5-sdk,
            python3,
            python3-pip,
            git,
            build-essential,
            your-new-package-here    <-- Add here
```

Then rebuild:

```bash
dpkg-buildpackage -us -uc -b
```

## Check Package Quality

```bash
lintian -I --show-overrides ../distiller-genesis_*.deb
```

## Package Details

- **Name**: distiller-genesis (cheeky!)
- **Type**: Meta-package for installing random stuff
- **Standards**: Debian Trixie (Policy 4.7.2, debhelper 14)
- **Dependencies**: Recommends only (not forced)
- **Removal**: Won't remove installed packages

## File Locations

- Package definition: `debian/control`
- Version history: `debian/changelog`
- Build rules: `debian/rules`
- License: `debian/copyright`

