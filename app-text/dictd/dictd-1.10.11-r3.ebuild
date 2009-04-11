# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dictd/dictd-1.10.11-r3.ebuild,v 1.11 2008/12/16 20:27:08 pva Exp $

inherit eutils autotools

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
		dbi? ( dev-db/libdbi )
		judy? ( dev-libs/judy )
		|| ( >=sys-apps/coreutils-6.10 sys-apps/mktemp )
		sys-apps/sed"
RDEPEND="${DEPEND}
		>=sys-apps/gawk-3.1.6"

pkg_setup() {
	enewgroup dictd
	enewuser dictd -1 -1 -1 dictd
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/dictd-1.10.11-colorit-nopp-fix.patch"
	epatch "${FILESDIR}/dictd-1.10.11-dictdplugin_popen-g++-4.3compile.patch"
	epatch "${FILESDIR}/dictd-1.10.11-dictd.8-man.patch"
	epatch "${FILESDIR}/dictd-1.10.11-dictl-konwert.patch"
	epatch "${FILESDIR}/dictd-1.10.11-dictd.c-alen-init.patch"
	epatch "${FILESDIR}/dictd-1.10.11-dictl-translit.patch"
	epatch "${FILESDIR}/dictd-1.10.11-automatic-plugins_build-failure.patch"
	eautoreconf
	
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's:libtool:glibtool:g' libmaa/Makefile.in Makefile.in
}

src_test() {
	if use ppc || use ppc64; then
		ewarn "Tests are known to fail on big-endian systems (ppc, ppc64)"
		ewarn "Skipping tests."
	else
		if ! hasq userpriv "${FEATURES}"; then
			# If dictd is run as root user (-userpriv) it drops its privileges to
			# dictd user and group. Give dictd group write access to test directory.
			chown :dictd "${WORKDIR}" "${S}/test"
			chmod 770 "${WORKDIR}" "${S}/test"
		fi
		emake test || die
	fi
}

src_compile() {
	# with-local-libmaa is needed because libmaa is not in the tree
	# because nothing in the whole wide world but dictd uses it.
	# There are no sources apart from those in dictd, no homepage, nothing.
	# Doesn't really make sense to split it off from dictd into its own package
	# and add that just for dictd.
	econf \
		$(use_with dbi) \
		$(use_with judy) \
		--sysconfdir="${EPREFIX}"/etc/dict \
		--with-cflags="${CFLAGS}" \
		--with-local-libmaa
	emake || die "make failed"
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
	elog "To start and use ${PN} you will have to emerge at least one dictionary from"
	elog "the app-dicts category with the package name starting with 'dictd-'."
	elog "To install all available dictionaries, emerge app-dicts/dictd-dicts."
	elog "${PN} will NOT start without at least one dictionary."
	echo
}
