default:
	@just --list

clean:
	rm -rf debian/.debhelper debian/files debian/*.log debian/*.substvars debian/debhelper-build-stamp
	rm -rf debian/distiller-genesis-common debian/distiller-genesis-cm5 debian/distiller-genesis-rockchip
	rm -f ../*.deb ../*.dsc ../*.tar.* ../*.changes ../*.buildinfo ../*.build
	rm -rf dist

build arch="all":
	#!/usr/bin/env bash
	set -e
	export DEB_BUILD_OPTIONS="parallel=$(nproc)"
	debuild -us -uc -b -d --lintian-opts --profile=debian
	mkdir -p dist
	mv ../*.deb dist/ 2>/dev/null || true
	rm -f ../*.{dsc,tar.*,changes,buildinfo,build}

changelog:
	dch -i
