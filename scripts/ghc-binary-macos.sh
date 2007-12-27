#!/usr/bin/env bash
# Copyright Gentoo Foundation 2007
EPREFIX=$(portageq envvar EPREFIX)
VERSION=6.8.2
PLATFORM=x86-macos

{ #stdout goes to /dev/null
tempdir=$(mktemp -d)
cd ${tempdir}
} >/dev/null
#env USE=ghcbootstrap emerge ghc
quickpkg ghc
{ #stdout goes to /dev/null
mv "$(portageq envvar PKGDIR)"/dev-lang/ghc-${VERSION}.tbz2 .
tar -xjf ghc-${VERSION}.tbz2 2>/dev/null
rm ghc-${VERSION}.tbz2
mv ./"${EPREFIX}"/usr .
rm -rf ./"${EPREFIX}"
"${EPREFIX}"/usr/lib/portage/bin/chpathtool usr foo "${EPREFIX}"/ /
for fix_me in $(find usr -not -name '*.o' -type f -exec /usr/bin/file {} + | awk -F : '$2 ~ /Mach-O/ {print $1}'); do
    install_name_tool -change /usr/lib/gcc/i686-apple-darwin9/4.0.1/libgcc_s.1.dylib /lib/libgcc_s.1.dylib ${fix_me}
done
# fix symlinks broken by chpathtool
rm foo/bin/ghc
rm foo/bin/ghci
ln -s ghc-${VERSION} foo/bin/ghc
ln -s ghci-${VERSION} foo/bin/ghci

rm -rf usr
sed -i s/nocona/prescott/g foo/bin/ghc-${VERSION}
mv foo usr
tar cjf ghc-bin-${VERSION}-${PLATFORM}.tbz2 usr
} >/dev/null

echo ${tempdir}/ghc-bin-${VERSION}-${PLATFORM}.tbz2
