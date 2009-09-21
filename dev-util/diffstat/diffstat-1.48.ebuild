# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/diffstat/diffstat-1.48.ebuild,v 1.4 2009/09/19 15:12:10 armin76 Exp $

DESCRIPTION="Display a histogram of diff changes"
HOMEPAGE="http://invisible-island.net/diffstat/diffstat.html"
SRC_URI="ftp://invisible-island.net/diffstat/${P}.tgz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

# NOTE: diffstat(1) auto-detects which decompressors are available, and switches
# off the ability to read diff compressed files in a specific format if the
# decompressor isn't found at build-time, even if you install it afterwards.
# There are three solutions:
# 1) Patch the build system to enable/disable a given decompressor, and provide
#    USE flags.
# 2) (R)DEPEND on all decompressors.
# 3) Warn the user by stating that if a decompressor is installed after
#    dev-util/diffstat, (s)he either needs to recompile this package, or set the
#    decompressor environment variable (eg DIFFSTAT_LZCAT_PATH).
#
# In the long term the first two solutions are flawed, because:
# 1) Adding USE flags for each new decompressor is obviously wrong (the user
#    would still need to recompile dev-util/diffstat just to obtain support for
#    a given decompressor).
# 2) Of keywording. An architecture team would either need to mask the USE flag,
#    drop its keyword from this package, or keyword every single decompressor.
#
# Thus, I think that if in the future a new decompressor support is added, it
# would be better to just warn the user. For the 1.48 release, aside from the
# ones that are installed by the system set (eg bzcat, zcat), only lzma-utils
# would be needed, but there are already a few important packages that depend
# on it, anyway.
#
# Also, pack(1) support is disabled, even though zcat from gzip(1) supports it.
# Not sure if anyone is using this, but it was marked as LEGACY on SUSv2, and
# disappeared on SUSv3. Nevertheless, if wanted set DIFFSTAT_PCAT_PATH to
# /bin/zcat.
DEPEND=""
RDEPEND=""

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES || die "dodoc failed"
}
