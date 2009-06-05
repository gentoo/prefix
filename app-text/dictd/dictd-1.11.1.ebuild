# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dictd/dictd-1.11.1.ebuild,v 1.8 2009/06/04 20:19:10 klausman Exp $

inherit eutils

DESCRIPTION="Dictionary Client/Server for the DICT protocol"
HOMEPAGE="http://www.dict.org/"
SRC_URI="mirror://sourceforge/dict/${P}.tar.gz"

SLOT="0"
# We install rfc so - ISOC-rfc
LICENSE="GPL-2 ISOC-rfc"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="dbi judy"

# <gawk-3.1.6 makes tests fail.
DEPEND="sys-apps/coreutils
		sys-libs/zlib
		dev-libs/libmaa
		dbi? ( dev-db/libdbi )
		judy? ( dev-libs/judy )
		|| ( >=sys-apps/coreutils-6.10 sys-apps/mktemp )"
RDEPEND="${DEPEND}
		>=sys-apps/gawk-3.1.6"

pkg_setup() {
	enewgroup dictd # used in src_test()
	enewuser dictd -1 -1 -1 dictd
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/dictd-1.10.11-colorit-nopp-fix.patch"
	
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's:libtool:glibtool:g' libmaa/Makefile.in Makefile.in
}

src_compile() {
	econf \
		$(use_with dbi plugin-dbi) \
		$(use_with judy plugin-judy) \
		--sysconfdir="${EPREFIX}"/etc/dict
	emake || die "make failed"
}

src_test() {
	if ! hasq userpriv "${FEATURES}"; then
		# If dictd is run as root user (-userpriv) it drops its privileges to
		# dictd user and group. Give dictd group write access to test directory.
		chown :dictd "${WORKDIR}" "${S}/test"
		chmod 770 "${WORKDIR}" "${S}/test"
	fi
	emake test || die
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	# Install docs
	dodoc README TODO ChangeLog ANNOUNCE NEWS || die "installing docs part 1 failed"
	dodoc doc/{dicf.ms,rfc.ms,rfc.sh,rfc2229.txt} || die "installing docs part 2 failed"
	dodoc doc/{security.doc,toc.ms} || die "installing docs part 3 failed"

	# conf files.
	insinto /etc/dict
	for f in dict.conf dictd.conf site.info colorit.conf; do
		doins "${FILESDIR}/1.10.11/${f}" || die "failed to install ${f}"
	done

	# startups for dictd
	newinitd "${FILESDIR}/1.10.11/dictd.initd" dictd || die "failed to install dictd.initd"
	newconfd "${FILESDIR}/1.10.11/dictd.confd" dictd || die "failed to install dictd.confd"
}

pkg_postinst() {
	echo
	elog "To start and use ${PN} you need to emerge at least one dictionary from"
	elog "the app-dicts category with the package name starting with 'dictd-'."
	elog "To install all available dictionaries, emerge app-dicts/dictd-dicts."
	elog "${PN} will NOT start without at least one dictionary."
	echo
}
