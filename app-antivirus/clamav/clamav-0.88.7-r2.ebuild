# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-antivirus/clamav/clamav-0.88.7-r2.ebuild,v 1.2 2007/01/23 15:22:40 genone Exp $

EAPI="prefix"

inherit eutils flag-o-matic fixheadtails

DESCRIPTION="Clam Anti-Virus Scanner"
HOMEPAGE="http://www.clamav.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="crypt logrotate mailwrapper milter onaccess selinux"

DEPEND="virtual/libc
	crypt? ( >=dev-libs/gmp-4.1.2 )
	milter? ( || ( mail-filter/libmilter mail-mta/sendmail ) )
	onaccess? ( sys-fs/dazuko )
	>=sys-libs/zlib-1.2.1-r3
	>=net-misc/curl-7.10.0
	>=sys-apps/sed-4"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-clamav )
	logrotate? ( app-admin/logrotate )
	sys-apps/grep"
PROVIDE="virtual/antivirus"

pkg_setup() {
	if use milter; then
		if [ ! -e "${EROOT}"/usr/lib/libmilter.a ] ; then
			ewarn "In order to enable milter support, clamav needs sendmail with enabled milter"
			ewarn "USE flag. Either recompile sendmail with milter USE flag enabled, or disable"
			ewarn "this flag for clamav as well to disable milter support."
			die "need milter-enabled sendmail"
		fi
	fi
	if use onaccess ; then
		echo
		ewarn "Warning: On access scan support is experimental!"
		echo
	fi
	enewgroup clamav
	enewuser clamav -1 -1 /dev/null clamav
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
		use mailwrapper && \
			myconf="${myconf} --with-sendmail=${EPREFIX}/usr/sbin/sendmail.sendmail"
	}

	ht_fix_file configure
	econf ${myconf} \
		$(use_enable onaccess clamuko) \
		--with-dbdir="${EPREFIX}"/var/lib/clamav || die
	emake || die
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc AUTHORS BUGS NEWS README ChangeLog FAQ INSTALL
	newconfd ${FILESDIR}/clamd.conf clamd
	newinitd ${FILESDIR}/clamd.rc clamd
	dodoc ${FILESDIR}/clamav-milter.README.gentoo

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
		-e "s:^\#\(LogTime\).*:\1:" \
		${ED}/etc/clamd.conf

	# Do the same for /etc/freshclam.conf
	sed -i -e "s:^\(Example\):\# \1:" \
		-e "s:.*\(PidFile\) .*:\1 ${EPREFIX}/var/run/clamav/freshclam.pid:" \
		-e "s:.*\(DatabaseOwner\) .*:\1 clamav:" \
		-e "s:^\#\(LogFile\) .*:\1 ${EPREFIX}/var/log/freshclam.log:" \
		-e "s:^\#\(LogTime\).*:\1:" \
		${ED}/etc/freshclam.conf

	if use milter ; then
		echo "START_MILTER=no" \
			>> ${ED}/etc/conf.d/clamd
		echo "MILTER_SOCKET=\"${EPREFIX}/var/run/clamav/clmilter.sock\"" \
			>>${ED}/etc/conf.d/clamd
		echo "MILTER_OPTS=\"-m 10 --timeout=0\"" \
			>>${ED}/etc/conf.d/clamd
	fi

	if use onaccess ; then
		dodir /etc/udev/rules.d
		echo "KERNEL==\"dazuko\", NAME=\"%k\", GROUP=\"clamav\", MODE=\"0660\"" \
			>${ED}/etc/udev/rules.d/60-dazuko.rules
	fi

	if use logrotate ; then
		diropts ""
		dodir /etc/logrotate.d
		insopts -m0644
		insinto /etc/logrotate.d
		newins ${FILESDIR}/${PN}.logrotate ${PN}
	fi
}

pkg_postinst() {
	echo
	ewarn "Warning: clamd and/or freshclam have not been restarted."
	ewarn "You should restart them with: ${EROOT}/etc/init.d/clamd restart"
	echo
	if use milter ; then
		elog "For simple instructions how to setup the clamav-milter"
		elog "read ${EROOT}/usr/share/doc/${PF}/clamav-milter.README.gentoo.gz"
		echo
	fi
}
