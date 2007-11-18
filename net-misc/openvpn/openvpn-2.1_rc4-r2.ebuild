# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openvpn/openvpn-2.1_rc4-r2.ebuild,v 1.2 2007/09/15 07:30:31 uberlord Exp $

EAPI="prefix"

inherit autotools eutils multilib

DESCRIPTION="OpenVPN is a robust and highly flexible tunneling application compatible with many OSes."
SRC_URI="http://openvpn.net/release/${P}.tar.gz
		ipv6? ( mirror://gentoo/${PN}-2.1-udp6.patch.bz2 )"
HOMEPAGE="http://openvpn.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd ~x86-macos"
IUSE="examples iproute2 ipv6 minimal pam passwordsave selinux ssl static threads userland_BSD"

DEPEND=">=dev-libs/lzo-1.07
	kernel_linux? (
		iproute2? ( sys-apps/iproute2 ) !iproute2? ( sys-apps/net-tools )
	)
	!minimal? ( pam? ( !kernel_Darwin? ( virtual/pam ) ) )
	selinux? ( sec-policy/selinux-openvpn )
	ssl? ( >=dev-libs/openssl-0.9.6 )"

pkg_setup() {
	if use iproute2 ; then
		if built_with_use sys-apps/iproute2 minimal ; then
			eerror "iproute2 support requires that sys-apps/iproute2 was not"
			eerror "built with the minimal USE flag"
			die "iproute2 support not available"
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}"-darwin.patch
	epatch "${FILESDIR}/${P}"-ip6-mss.patch
	use ipv6 && epatch "${WORKDIR}/${PN}"-2.1-udp6.patch
	eautoreconf
}

src_compile() {
	local myconf=""
	# We cannot use use_enable with iproute2 as the Makefile stupidly
	# enables it with --disable-iproute2
	use iproute2 && myconf="${myconf} --enable-iproute2"
	if use minimal ; then
		myconf="${myconf} --disable-plugins"
		myconf="${myconf} --disable-pkcs11"
	fi

	econf ${myconf} \
		$(use_enable ipv6) \
		$(use_enable passwordsave password-save) \
		$(use_enable ssl) \
		$(use_enable ssl crypto) \
		$(use_enable threads pthread) \
		|| die "configure failed"

	use static && sed -i -e '/^LIBS/s/LIBS = /LIBS = -static /' Makefile

	emake || die "make failed"

	if ! use minimal ; then
		cd plugin
		for i in $( ls 2>/dev/null ); do
			[[ ${i} == "README" || ${i} == "examples" ]] && continue
			[[ ${i} == "auth-pam" ]] && ! use pam && continue
			einfo "Building ${i} plugin"
			cd "${i}"
			emake TARGET_DIR="${EPREFIX}"/usr/$(get_libdir)/${PN} || die "make failed"
			cd ..
		done
		cd ..
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# install documentation
	dodoc AUTHORS ChangeLog PORTS README

	# Empty dir
	dodir /etc/openvpn
	keepdir /etc/openvpn

	# Install some helper scripts
	exeinto /etc/openvpn
	cp "${FILESDIR}"/up.sh "${FILESDIR}"/down.sh "${T}"
	eprefixify "${T}"/{up,down}.sh
	doexe "${T}/up.sh"
	doexe "${T}/down.sh"

	# Install the init script and config file
	cp "${FILESDIR}"/${PN}-2.1.init "${T}"
	eprefixify "${T}"/${PN}-2.1.init
	newinitd "${T}"/${PN}-2.1.init openvpn
	newconfd "${FILESDIR}/${PN}-2.1.conf" openvpn

	# install examples, controlled by the respective useflag
	if use examples ; then
		# dodoc does not supportly support directory traversal, #15193
		insinto /usr/share/doc/${PF}/examples
		doins -r sample-{config-files,keys,scripts} contrib
		prepalldocs
	fi

	# Install plugins and easy-rsa
	if ! use minimal ; then
		cd easy-rsa/2.0
		make install "DESTDIR=${ED}/usr/share/${PN}/easy-rsa"
		cd ../..

		exeinto "/usr/$(get_libdir)/${PN}"
		doexe plugin/*/*.so
	fi
}

pkg_postinst() {
	# Add openvpn user so openvpn servers can drop privs
	# Clients should run as root so they can change ip addresses,
	# dns information and other such things.
	enewgroup openvpn
	enewuser openvpn "" "" "" openvpn

	if [[ -n $(ls /etc/openvpn/*/local.conf 2>/dev/null) ]] ; then
		ewarn "WARNING: The openvpn init script has changed"
		ewarn ""
	fi

	einfo "The openvpn init script expects to find the configuration file"
	einfo "openvpn.conf in /etc/openvpn along with any extra files it may need."
	einfo ""
	einfo "To create more VPNs, simply create a new .conf file for it and"
	einfo "then create a symlink to the openvpn init script from a link called"
	einfo "openvpn.newconfname - like so"
	einfo "   cd /etc/openvpn"
	einfo "   ${EDITOR##*/} foo.conf"
	einfo "   cd /etc/init.d"
	einfo "   ln -s openvpn openvpn.foo"
	einfo ""
	einfo "You can then treat openvpn.foo as any other service, so you can"
	einfo "stop one vpn and start another if you need to."

	if grep -Eq "^[ \t]*(up|down)[ \t].*" ${EROOT}/etc/openvpn/*.conf 2>/dev/null ; then
		ewarn ""
		ewarn "WARNING: If you use the remote keyword then you are deemed to be"
		ewarn "a client by our init script and as such we force up,down scripts."
		ewarn "These scripts call /etc/openvpn/\$SVCNAME-{up,down}.sh where you"
		ewarn "can move your scripts to."
	fi

	if ! use minimal ; then
		einfo ""
		einfo "plugins have been installed into /usr/$(get_libdir)/${PN}"
	fi
}
