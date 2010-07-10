# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openvpn/openvpn-2.1_rc21.ebuild,v 1.1 2009/11/15 14:23:26 cedk Exp $

inherit eutils multilib toolchain-funcs autotools prefix

IPV6_VERSION="0.4.10"
DESCRIPTION="OpenVPN is a robust and highly flexible tunneling application compatible with many OSes."
SRC_URI="http://openvpn.net/release/${P}.tar.gz
		ipv6? (
			http://cloud.github.com/downloads/jjo/openvpn-ipv6/${P}-ipv6-${IPV6_VERSION}.patch.gz
		)
		eurephia? (
			mirror://sourceforge/eurephia/${P}_eurephia.patch
		)"
HOMEPAGE="http://openvpn.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="eurephia examples iproute2 ipv6 minimal pam passwordsave selinux ssl static pkcs11 threads userland_BSD"

DEPEND=">=dev-libs/lzo-1.07
	kernel_linux? (
		iproute2? ( sys-apps/iproute2 ) !iproute2? ( sys-apps/net-tools )
	)
	!minimal? ( pam? ( !kernel_Darwin? ( virtual/pam ) ) )
	selinux? ( sec-policy/selinux-openvpn )
	ssl? ( >=dev-libs/openssl-0.9.6 )
	pkcs11? ( >=dev-libs/pkcs11-helper-1.05 )"
RDEPEND="${DEPEND}"

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

	epatch "${FILESDIR}/${PN}-2.1_rc13-peercred.patch"
	epatch "${FILESDIR}"/openvpn-2.1_rc20-pkcs11.patch
	epatch "${FILESDIR}"/openvpn-2.1_rc4-darwin.patch
	use ipv6 && epatch "${WORKDIR}"/${P}-ipv6-${IPV6_VERSION}.patch
	use eurephia && epatch "${DISTDIR}/${P}_eurephia.patch"
	sed -i \
		-e "s/gcc \${CC_FLAGS}/\${CC} \${CFLAGS} -Wall/" \
		-e "s/-shared/-shared \${LDFLAGS}/" \
		plugin/*/Makefile || die "sed failed"
	eautoreconf
}

src_compile() {
	local myconf=""

	if use minimal ; then
		myconf="${myconf} --disable-plugins"
		myconf="${myconf} --disable-pkcs11"
	else
		myconf="$(use_enable pkcs11)"
	fi

	econf ${myconf} \
		$(use_enable passwordsave password-save) \
		$(use_enable ssl) \
		$(use_enable ssl crypto) \
		$(use_enable threads pthread) \
		$(use_enable iproute2) \
		|| die "configure failed"

	use static && sed -i -e '/^LIBS/s/LIBS = /LIBS = -static /' Makefile

	emake || die "make failed"

	if ! use minimal ; then
		cd plugin
		for i in $( ls 2>/dev/null ); do
			[[ ${i} == "README" || ${i} == "examples" || ${i} == "defer" ]] && continue
			[[ ${i} == "auth-pam" ]] && ! use pam && continue
			einfo "Building ${i} plugin"
			cd "${i}"
			emake CC=$(tc-getCC) TARGET_DIR="${EPREFIX}"/usr/$(get_libdir)/${PN} || die "make failed"
			cd ..
		done
		cd ..
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# install documentation
	dodoc AUTHORS ChangeLog PORTS README
	use eurephia && dodoc README.eurephia

	# remove empty dir
	rmdir "${ED}/usr/share/doc/openvpn"

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

	if grep -Eq "^[ \t]*(up|down)[ \t].*" "${EROOT}/etc/openvpn"/*.conf 2>/dev/null ; then
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

	if use ipv6 ; then
		einfo ""
		einfo "This build contains IPv6-Patch from JuanJo Ciarlante."
		einfo "For more information please visit:"
		einfo "http://github.com/jjo/openvpn-ipv6"
	fi

	if use eurephia ; then
		einfo ""
		einfo "This build contains eurephia patch."
		einfo "For more information please visit:"
		einfo "http://www.eurephia.net/"
	fi
}
