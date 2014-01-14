#!/usr/bin/env bash
# Copyright 2007-2014 Gentoo Foundation; Distributed under the GPL v2
EPREFIX=$(portageq envvar EPREFIX)
VERSION=6.8.2
GCC_VERSION=4.0.1
UNAME_P=$(uname -p)
case ${UNAME_P} in
    i386) PLATFORM_PORTAGE=x86; PLATFORM_GCC=i686;;
    powerpc) PLATFORM_PORTAGE=ppc; PLATFORM_GCC=ppc;;
    *) echo "platform not supported by this script"; exit 0;;
esac
UNAME_R=$(uname -r)
SYSTEM_VERSION=${UNAME_R%%.*}

tempdir=$(mktemp -d)
cd ${tempdir}

if [[ -z ${NO_EMERGE} ]]; then
    env CFLAGS='-O2 -pipe' USE=ghcbootstrap emerge ghc
fi
quickpkg ghc

mv "$(portageq envvar PKGDIR)"/dev-lang/ghc-${VERSION}.tbz2 .
tar -xjf ghc-${VERSION}.tbz2 2>/dev/null
rm ghc-${VERSION}.tbz2
mv ./"${EPREFIX}"/usr .
rm -rf ./"${EPREFIX}"

if grep -q -- '-\(march\|mtune\|mcpu\)' usr/bin/ghc-${VERSION}; then
    echo ERROR: the CFLAGS used to compile ghc are not portable!
    exit 0
fi

# remove old prefix
"${EPREFIX}"/usr/lib/portage/bin/chpathtool usr foo "${EPREFIX}"/ / >/dev/null
# fix symlinks broken by chpathtool
rm foo/bin/ghc{,i}
ln -s ghc-${VERSION} foo/bin/ghc
ln -s ghci-${VERSION} foo/bin/ghci

# fix install_names
libgcc_old=/usr/lib/gcc/${PLATFORM_GCC}-apple-darwin${SYSTEM_VERSION}/${GCC_VERSION}
for fix_me in $(find foo -not -name '*.o' -type f -exec /usr/bin/file {} + | awk -F : '$2 ~ /Mach-O/ {print $1}'); do
    install_name_tool -change {${libgcc_old},/lib}/libgcc_s.1.dylib ${fix_me}
done

rm -rf usr

mv foo usr
tar -cjf ghc-bin-${VERSION}-${PLATFORM_PORTAGE}-macos.tbz2 usr
rm -rf usr

echo ${tempdir}/ghc-bin-${VERSION}-${PLATFORM_PORTAGE}-macos.tbz2
