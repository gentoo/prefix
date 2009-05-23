# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/ntp/ntp-4.2.4_p7.ebuild,v 1.5 2009/05/21 18:35:03 armin76 Exp $

inherit eutils toolchain-funcs flag-o-matic

MY_P=${P/_p/p}
DESCRIPTION="Network Time Protocol suite/programs"
HOMEPAGE="http://www.ntp.org/"
SRC_URI="http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-${PV:0:3}/${MY_P}.tar.gz
	mirror://gentoo/${MY_P}-manpages.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~m68k-mint"
IUSE="caps debug ipv6 openntpd parse-clocks selinux ssl zeroconf"

DEPEND=">=sys-libs/ncurses-5.2
	>=sys-libs/readline-4.1
	kernel_linux? ( caps? ( sys-libs/libcap ) )
	zeroconf? ( || ( net-dns/avahi net-misc/mDNSResponder ) )
	!openntpd? ( !net-misc/openntpd )
	ssl? ( dev-libs/openssl )
	selinux? ( sec-policy/selinux-ntp )"
PDEPEND="openntpd? ( net-misc/openntpd )"

S=${WORKDIR}/${MY_P}

hax_bitkeeper() {
	# the makefiles have support for bk ...
	# basically we have to do this or bk will try to write
	# to files in /opt/bitkeeper causing sandbox violations ;(
	mkdir -p "${T}"/fakebin
	echo "#!${EPREFIX}/bin/sh"$'\n'"exit 1" > "${T}"/fakebin/bk
	chmod a+x "${T}"/fakebin/bk
	export PATH="${T}/fakebin:${PATH}"
}

pkg_setup() {
	enewgroup ntp 123
	enewuser ntp 123 -1 /dev/null ntp

	if use zeroconf && has_version net-dns/avahi && ! built_with_use net-dns/avahi mdnsresponder-compat ; then
		eerror "You need to recompile net-dns/avahi with mdnsresponder-compat USE flag"
		die "net-dns/avahi is missing required mdnsresponder-compat support"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Needs to be ported ...
	#epatch "${FILESDIR}"/4.2.0.20040617-hostname.patch
	epatch "${FILESDIR}"/${PN}-4.2.4_p5-adjtimex.patch #254030
	epatch "${FILESDIR}"/${PN}-4.2.4_p7-nano.patch #270483
	append-cppflags -D_GNU_SOURCE #264109

	sed -i \
		-e 's:md5\.h:touch_not_my_md5:g' \
		-e 's:-lelf:-la_doe_a_deer_a_female_deer:g' \
		-e 's:-lmd5:-li_dont_want_no_stinkin_md5:g' \
		configure || die "sed failed"
}

src_compile() {
	hax_bitkeeper
	# blah, no real configure options #176333
	export ac_cv_header_dns_sd_h=$(use zeroconf && echo yes || echo no)
	export ac_cv_lib_dns_sd_DNSServiceRegister=${ac_cv_header_dns_sd_h}
	econf \
		$(use_enable caps linuxcaps) \
		$(use_enable parse-clocks) \
		$(use_enable ipv6) \
		$(use_enable debug debugging) \
		$(use_with ssl crypto) \
		|| die
	emake || die
}

src_install() {
	hax_bitkeeper
	emake install DESTDIR="${D}" || die "install failed"
	# move ntpd/ntpdate to sbin #66671
	dodir /usr/sbin
	mv "${ED}"/usr/bin/{ntpd,ntpdate} "${ED}"/usr/sbin/ || die "move to sbin"

	dodoc ChangeLog INSTALL NEWS README TODO WHERE-TO-START
	doman "${WORKDIR}"/man/*.[58]
	dohtml -r html/*

	insinto /usr/share/ntp
	doins "${FILESDIR}"/ntp.conf
	cp -r scripts/* "${ED}"/usr/share/ntp/ || die
	fperms -R go-w /usr/share/ntp
	find "${ED}"/usr/share/ntp \
		'(' \
		-name '*.in' -o \
		-name 'Makefile*' -o \
		-name support \
		')' \
		-exec rm -r {} \;

	insinto /etc
	doins "${FILESDIR}"/ntp.conf
	newinitd "${FILESDIR}"/ntpd.rc ntpd
	newconfd "${FILESDIR}"/ntpd.confd ntpd
	newinitd "${FILESDIR}"/ntp-client.rc ntp-client
	newconfd "${FILESDIR}"/ntp-client.confd ntp-client
	use caps || dosed "s|-u ntp:ntp||" /etc/conf.d/ntpd
	dosed "s:/usr/bin:/usr/sbin:" /etc/init.d/ntpd

	keepdir /var/lib/ntp
	fowners ntp:ntp /var/lib/ntp

	if use openntpd ; then
		cd "${ED}"
		rm usr/sbin/ntpd || die
		rm -r var/lib
		rm etc/{conf,init}.d/ntpd
		rm usr/share/man/*/ntpd.8 || die
	fi
}

pkg_postinst() {
	ewarn "You can find an example /etc/ntp.conf in /usr/share/ntp/"
	ewarn "Review /etc/ntp.conf to setup server info."
	ewarn "Review /etc/conf.d/ntpd to setup init.d info."
	echo
	elog "The way ntp sets and maintains your system time has changed."
	elog "Now you can use /etc/init.d/ntp-client to set your time at"
	elog "boot while you can use /etc/init.d/ntpd to maintain your time"
	elog "while your machine runs"
	if grep -qs '^[^#].*notrust' "${EROOT}"/etc/ntp.conf ; then
		echo
		eerror "The notrust option was found in your /etc/ntp.conf!"
		ewarn "If your ntpd starts sending out weird responses,"
		ewarn "then make sure you have keys properly setup and see"
		ewarn "http://bugs.gentoo.org/41827"
	fi
}
