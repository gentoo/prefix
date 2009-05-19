# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-antivirus/clamav/clamav-0.95.1.ebuild,v 1.8 2009/05/18 19:43:13 ranger Exp $

inherit autotools eutils flag-o-matic fixheadtails multilib versionator prefix

# for when rc1 is appended to release candidates:
MY_PV=$(replace_version_separator 3 '');
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Clam Anti-Virus Scanner"
HOMEPAGE="http://www.clamav.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="bzip2 clamdtop crypt iconv milter selinux ipv6"

COMMON_DEPEND="bzip2? ( app-arch/bzip2 )
	crypt? ( >=dev-libs/gmp-4.1.2 )
	milter? ( || ( mail-filter/libmilter mail-mta/sendmail ) )
	iconv? ( virtual/libiconv )
	clamdtop? ( sys-libs/ncurses )
	>=sys-libs/zlib-1.2.1-r3
	>=sys-apps/sed-4"

DEPEND="${COMMON_DEPEND}
	>=dev-util/pkgconfig-0.20"

RDEPEND="${COMMON_DEPEND}
	selinux? ( sec-policy/selinux-clamav )
	sys-apps/grep"

PROVIDE="virtual/antivirus"

RESTRICT="test"

pkg_setup() {
	if use milter; then
		if [ ! -e "${EPREFIX}"/usr/$(get_libdir)/libmilter.a ] ; then
			ewarn "In order to enable milter support, clamav needs sendmail with enabled milter"
			ewarn "USE flag, or mail-filter/libmilter package."
		fi
	fi
	enewgroup clamav
	enewuser clamav -1 -1 /dev/null clamav
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.92.1-interix.patch
	epatch "${FILESDIR}"/${PN}-0.93-prefix.patch
	eprefixify "${S}"/configure.in
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-nls.patch"
}

src_compile() {
	has_version =sys-libs/glibc-2.2* && filter-lfs-flags

	local myconf

	# we depend on fixed zlib, so we can disable this check to prevent redundant
	# warning (bug #61749)
	myconf="${myconf} --disable-zlib-vcheck"
	# use id utility instead of /etc/passwd parsing (bug #72540)
	myconf="${myconf} --enable-id-check"
	use milter && {
		myconf="${myconf} --enable-milter"
	}

	[[ ${CHOST} == *-interix* ]] && {
		export ac_cv_func_poll=no
		export ac_cv_header_inttypes_h=no
		export ac_cv_func_mmap_fixed_mapped=yes
		myconf="${myconf} --disable-gethostbyname_r"
	}

	ht_fix_file configure
	econf ${myconf} \
		$(use_enable bzip2) \
		$(use_enable ipv6) \
		$(use_enable clamdtop) \
		$(use_with iconv) \
		--disable-experimental \
		--disable-clamav \
		--with-dbdir="${EPREFIX}"/var/lib/clamav || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS NEWS README ChangeLog FAQ
	newconfd "${FILESDIR}"/clamd.conf clamd
	newinitd "${FILESDIR}"/clamd.rc clamd
	dodoc "${FILESDIR}"/clamav-milter.README.gentoo

	dodir /var/run/clamav
	keepdir /var/run/clamav
	fowners clamav:clamav /var/run/clamav
	dodir /var/log/clamav
	keepdir /var/log/clamav
	fowners clamav:clamav /var/log/clamav

	# Change /etc/clamd.conf to be usable out of the box
	sed -i -e "s:^\(Example\):\# \1:" \
		-e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/var/run/clamav/clamd.pid:" \
		-e "s:.*\(LocalSocket\) .*:\1 ${EPREFIX}/var/run/clamav/clamd.sock:" \
		-e "s:.*\(User\) .*:\1 clamav:" \
		-e "s:^\#\(LogFile\) .*:\1 ${EPREFIX}/var/log/clamav/clamd.log:" \
		-e "s:^\#\(LogTime\).*:\1 yes:" \
		-e "s:^\#\(AllowSupplementaryGroups\).*:\1 yes:" \
		"${ED}"/etc/clamd.conf

	# Do the same for /etc/freshclam.conf
	sed -i -e "s:^\(Example\):\# \1:" \
		-e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/var/run/clamav/freshclam.pid:" \
		-e "s:.*\(DatabaseOwner\) .*:\1 clamav:" \
		-e "s:^\#\(UpdateLogFile\) .*:\1 ${EPREFIX}/var/log/clamav/freshclam.log:" \
		-e "s:^\#\(NotifyClamd\).*:\1 ${EPREFIX}/etc/clamd.conf:" \
		-e "s:^\#\(ScriptedUpdates\).*:\1 yes:" \
		-e "s:^\#\(AllowSupplementaryGroups\).*:\1 yes:" \
		"${ED}"/etc/freshclam.conf

	if use milter; then
	   # And again same for /etc/clamav-milter.conf
	   # MilterSocket one to include ' /' because there is a 2nd line for
	   # inet: which we want to leave
	   sed -i -e "s:^\(Example\):\# \1:" \
	       -e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/var/run/clamav/clamav-milter.pid:" \
	       -e "s:^\#\(ClamdSocket\) .*:\1 ${EPREFIX}/var/run/clamav/clamd.sock:" \
	       -e "s:.*\(User\) .*:\1 clamav:" \
	       -e "s:^\#\(MilterSocket\) /.*:\1 ${EPREFIX}/var/run/clamav/clamav-milter.sock:" \
	       -e "s:^\#\(AllowSupplementaryGroups\).*:\1 yes:" \
	       -e "s:^\#\(LogFile\) .*:\1 ${EPREFIX}/var/log/clamav/clamav-milter.log:" \
	       "${ED}"/etc/clamav-milter.conf
	fi

	if use milter ; then
		echo "
START_MILTER=no
MILTER_NICELEVEL=19" \
			>> "${ED}"/etc/conf.d/clamd
		echo "MILTER_SOCKET=\"${EPREFIX}/var/run/clamav/clmilter.sock\"" \
			>>"${ED}"/etc/conf.d/clamd
		echo "MILTER_OPTS=\"-m 10 --timeout=0\"" \
			>>"${ED}"/etc/conf.d/clamd
	fi

	diropts ""
	dodir /etc/logrotate.d
	insopts -m0644
	insinto /etc/logrotate.d
	newins ${FILESDIR}/${PN}.logrotate ${PN}
}

pkg_postinst() {
	echo
	if use milter ; then
		elog "For simple instructions how to setup the clamav-milter"
		elog "read the clamav-milter.README.gentoo in /usr/share/doc/${PF}"
		echo
	fi
	ewarn "The soname for libclamav has changed in clamav-0.95."
	ewarn "If you have upgraded from that or earlier version, it is"
	ewarn "recommended to run revdep-rebuild, in order to fix anything"
	ewarn "that links against libclamav.so library."
	echo
}
