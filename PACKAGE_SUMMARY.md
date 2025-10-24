# distiller-genesis Package Summary

## Package Information
- **Name**: distiller-genesis
- **Type**: Meta-package (cheeky name indeed!)
- **Architecture**: all
- **Section**: metapackages
- **Priority**: optional
- **Standards-Version**: 4.7.2 (Debian Policy, February 2025)
- **Debhelper Compat**: 14 (recommended for Debian Trixie)

## Debian Trixie Compliance

### Updated to Latest Standards
- **Policy 4.7.2**: Latest Debian Policy Manual (Feb 2025)
- **Debhelper 14**: Stable compat level for Trixie production use
- **FHS 3.0**: Compliant (meta-package installs no files, so N/A)
- **Standards-Version**: Now mandatory field (included)

### Key Policy Updates Applied
1. No files installed to legacy directories (/bin, /lib, /sbin) - N/A for meta-package
2. Standards-Version field is mandatory - Added
3. Meta-package best practices followed per Debian Developer's Reference

## Created Files

### Core Debian Package Files
✓ **debian/control** - Updated with Trixie standards
  - debhelper-compat (= 14)
  - Standards-Version: 4.7.2
  - Recommends instead of hard Depends (proper meta-package pattern)
  
✓ **debian/copyright** - MIT license, machine-readable format 1.0
✓ **debian/rules** - Minimal rules for meta-package
✓ **debian/changelog** - Version 1.0.0 initial release
✓ **debian/compat** - Level 14 (stable for Trixie)

### Maintainer Scripts (all executable, minimal)
✓ **debian/preinst** - Placeholder (no operations)
✓ **debian/postinst** - Simple notification only
✓ **debian/prerm** - Placeholder (no operations)
✓ **debian/postrm** - Removal notification only

**Note**: Scripts are intentionally minimal - meta-packages should not perform system configuration.

### Package Configuration
✓ **debian/gbp.conf** - git-buildpackage configuration
✓ **debian/distiller-genesis.lintian-overrides** - Meta-package overrides
✓ **debian/distiller-genesis.install** - Empty (meta-packages install no files)
✓ **debian/source/format** - 3.0 (native)

### Documentation
✓ **README.md** - Complete package documentation

## Meta-Package Design

### Dependencies (Proper Meta-Package Pattern)
- **Depends**: ${misc:Depends} only (debhelper substvar)
- **Recommends**: distiller-cm5-sdk, python3, python3-pip, git, build-essential
- **Suggests**: distiller-examples, distiller-docs

This follows Debian best practices:
- Hard dependencies only on debhelper variables
- Actual packages in Recommends (installed by default, can be removed)
- Optional packages in Suggests

### Purpose
From the package description:
> This meta-package provides a convenient way to install various components
> for the Distiller CM5 platform. Being a meta-package, it primarily serves
> to pull in recommended dependencies.
>
> Removing this package will not affect the installed components, which can
> be managed independently.

Perfect for "installing random stuff" - just add to Recommends/Suggests!

## FHS Compliance
Meta-packages typically install no files, so FHS compliance is not applicable.
If files are added later, must comply with FHS 3.0 per Debian Policy 4.7.2.

## To Build

```bash
# Debian Trixie (requires debhelper >= 14)
dpkg-buildpackage -us -uc -b

# Check compliance
lintian -I --show-overrides ../distiller-genesis_*.deb
```

## To Add More "Random Stuff"

Edit `debian/control`:

```
Recommends: distiller-cm5-sdk,
            python3,
            your-new-package-here,
            another-package
```

Then rebuild. Easy!

## Key Changes from Original

1. **Name**: meta-distiller → distiller-genesis
2. **Standards**: 4.6.2 → 4.7.2 (latest)
3. **Debhelper**: 13 → 14 (recommended for Trixie)
4. **Dependencies**: Moved from Depends to Recommends (proper meta-package)
5. **Maintainer scripts**: Drastically simplified (no system configuration)
6. **Description**: Clarified meta-package nature and removal behavior
7. **Lintian overrides**: Removed unnecessary overrides for simplified scripts

## Compliance Checklist

- [x] Debian Policy 4.7.2 compliant
- [x] Debhelper compat 14 (stable for Trixie)
- [x] FHS 3.0 compliant (N/A - no files)
- [x] Meta-package best practices followed
- [x] Proper dependency handling (Recommends/Suggests)
- [x] Minimal maintainer scripts
- [x] Clear user communication about removal behavior
- [x] Machine-readable copyright format 1.0
- [x] Standards-Version field present (mandatory)
- [x] Rules-Requires-Root: no (best practice)

