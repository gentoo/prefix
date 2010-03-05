# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openssh/openssh-5.3_p1-r1.ebuild,v 1.3 2009/10/11 06:04:03 robbat2 Exp $

inherit eutils flag-o-matic multilib autotools pam

# Make it more portable between straight releases
# and _p? releases.
PARCH=${P/_/}

HPN_PATCH="${PARCH}-hpn13v6-gentoo.diff.gz"
LDAP_PATCH="${PARCH/openssh/openssh-lpk}-0.3.11.patch.gz"
PKCS11_PATCH="${PARCH/3p1/2}pkcs11-0.26.tar.bz2"
X509_VER="6.2.1" X509_PATCH="${PARCH}+x509-${X509_VER}.diff.gz"

DESCRIPTION="Port of OpenBSD's free SSH release"
HOMEPAGE="http://www.openssh.org/"
SRC_URI="mirror://openbsd/OpenSSH/portable/${PARCH}.tar.gz
	${HPN_PATCH:+hpn? ( http://www.psc.edu/networking/projects/hpn-ssh/${HPN_PATCH} )}
	${LDAP_PATCH:+ldap? ( mirror://gentoo/${LDAP_PATCH} )}
	${PKCS11_PATCH:+pkcs11? ( http://alon.barlev.googlepages.com/${PKCS11_PATCH} )}
	${X509_PATCH:+X509? ( http://roumenpetrov.info/openssh/x509-${X509_VER}/${X509_PATCH} )}"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="hpn kerberos ldap libedit pam pkcs11 selinux skey smartcard static tcpd X X509"

RDEPEND="pam? ( virtual/pam )
	kerberos? ( virtual/krb5 )
	selinux? ( >=sys-libs/libselinux-1.28 )
	skey? ( >=sys-auth/skey-1.1.5-r1 )
	ldap? ( net-nds/openldap )
	libedit? ( dev-libs/libedit )
	>=dev-libs/openssl-0.9.6d
	>=sys-libs/zlib-1.2.3
	smartcard? ( dev-libs/opensc )
	pkcs11? ( dev-libs/pkcs11-helper )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	X? ( x11-apps/xauth )
	userland_GNU? ( sys-apps/shadow )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	virtual/os-headers
	sys-devel/autoconf"
RDEPEND="${RDEPEND}
	pam? ( >=sys-auth/pambase-20081028 )"
PROVIDE="virtual/ssh"

S=${WORKDIR}/${PARCH}

pkg_setup() {
	# this sucks, but i'd rather have people unable to `emerge -u openssh`
	# than not be able to log in to their server any more
	maybe_fail() { [[ -z ${!2} ]] && use ${1} && echo ${1} ; }
	local fail="
		$(maybe_fail ldap LDAP_PATCH)
		$(maybe_fail pkcs11 PKCS11_PATCH)
		$(maybe_fail X509 X509_PATCH)
	"
	fail=$(echo ${fail})
	if [[ -n ${fail} ]] ; then
		eerror "Sorry, but this version does not yet support features"
		eerror "that you requested:	 ${fail}"
		eerror "Please mask ${PF} for now and check back later:"
		eerror " # echo '=${CATEGORY}/${PF}' >> /etc/portage/package.mask"
		die "booooo"
	fi
}

src_unpack() {
	unpack ${PARCH}.tar.gz
	cd "${S}"

	sed -i \
		-e "/_PATH_XAUTH/s:/usr/X11R6/bin/xauth:${EPREFIX}/usr/bin/xauth:" \
		pathnames.h || die

	if use pkcs11 ; then
		cd "${WORKDIR}"
		unpack "${PKCS11_PATCH}"
		cd "${S}"
		# This patch is included with X509, so exclude it if X509 is going to be
		# applied.
		use X509 && mv -f "${WORKDIR}"/*pkcs11*/1000_all_log.patch "${WORKDIR}"
		# Now apply pkcs11
		EPATCH_OPTS="-p1" epatch "${WORKDIR}"/*pkcs11*/{1,2,4}*
		# And some glue
		epatch "${FILESDIR}"/${PN}-5.3_p1-pkcs11-hpn-glue.patch
	fi
	if use X509 ; then
		# Apply X509 patch
		epatch "${DISTDIR}"/${X509_PATCH}
		# Apply glue so that HPN will still work after X509
		epatch "${FILESDIR}"/${PN}-5.2_p1-x509-hpn-glue.patch
	fi
	use smartcard && epatch "${FILESDIR}"/openssh-3.9_p1-opensc.patch
	if ! use X509 ; then
		if [[ -n ${LDAP_PATCH} ]] && use ldap ; then
			# The patch for bug 210110 64-bit stuff is now included.
			epatch "${DISTDIR}"/${LDAP_PATCH}
			epatch "${FILESDIR}"/${PN}-5.2p1-ldap-stdargs.diff #266654
		fi
		#epatch "${DISTDIR}"/openssh-5.2p1-gsskex-all-20090726.patch #115553 #216932 #279488
		#epatch "${FILESDIR}"/${P}-gsskex-fix.patch
	else
		use ldap && ewarn "Sorry, X509 and ldap don't get along, disabling ldap"
	fi
	epatch "${FILESDIR}"/${PN}-4.7_p1-GSSAPI-dns.patch #165444 integrated into gsskex
	[[ -n ${HPN_PATCH} ]] && use hpn && epatch "${DISTDIR}"/${HPN_PATCH}
	epatch "${FILESDIR}"/${PN}-4.7p1-selinux.diff #191665
	epatch "${FILESDIR}"/${PN}-5.2_p1-autoconf.patch

	# in 5.2p1, the AES-CTR multithreaded variant is temporarily broken, and
	# causes random hangs when combined with the -f switch of ssh.
	# To avoid this, we change the internal table to use the non-multithread
	# version for the meantime.
	sed -i \
		-e '/aes...-ctr.*SSH_CIPHER_SSH2/s,evp_aes_ctr_mt,evp_aes_128_ctr,' \
		cipher.c || die

	sed -i "s:-lcrypto:$(pkg-config --libs openssl):" configure{,.ac} || die

	epatch "${FILESDIR}"/${PN}-5.1_p1-apple-copyfile.patch
	epatch "${FILESDIR}"/${PN}-5.1_p1-apple-getpwuid.patch
	epatch "${FILESDIR}"/${P}-interix.patch

	# when installed as non-admin on interix6, chmoding with +s fails! ...
	# (btw: administrator uid is constant across all windows versions).
	if [[ ${CHOST} == *-interix6* ]]; then
		if [[ $(id -u) != 197108 ]]; then
			epatch "${FILESDIR}"/${P}-interix6-setuid.patch
		fi
	fi


	# Disable PATH reset, trust what portage gives us. bug 254615
	sed -i -e 's:^PATH=/:#PATH=/:' configure || die

	eautoreconf
}

static_use_with() {
	local flag=$1
	if use static && use ${flag} ; then
		ewarn "Disabling '${flag}' support because of USE='static'"
		# rebuild args so that we invert the first one (USE flag)
		# but otherwise leave everything else working so we can
		# just leverage use_with
		shift
		[[ -z $1 ]] && flag="${flag} ${flag}"
		set -- !${flag} "$@"
	fi
	use_with "$@"
}

src_compile() {
	addwrite /dev/ptmx
	addpredict /etc/skey/skeykeys #skey configure code triggers this

	local myconf=""
	use static && append-ldflags -static

	# for some reason the stack-protector detection code doesn't really work on
	# solaris, so don't try it, FreeMiNT neither
	[[ ${CHOST} == *-solaris* || ${CHOST} == *-mint* ]] && \
		myconf="${myconf} --without-stackprotect"
	
	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_poll=no
		export ac_cv_header_poll_h=no
	fi

	econf \
		--with-ldflags="${LDFLAGS}" \
		--disable-strip \
		--sysconfdir="${EPREFIX}"/etc/ssh \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/misc \
		--datadir="${EPREFIX}"/usr/share/openssh \
		--with-privsep-path="${EPREFIX}"/var/empty \
		--with-pid-dir="${EPREFIX}"/var/run \
		--with-privsep-user=sshd \
		--with-md5-passwords \
		--with-ssl-engine \
		$(static_use_with pam) \
		$(static_use_with kerberos kerberos5 "${EPREFIX}"/usr) \
		${LDAP_PATCH:+$(use ldap && use_with ldap)} \
		$(use_with libedit) \
		${PKCS11_PATCH:+$(use pkcs11 && static_use_with pkcs11)} \
		$(use_with selinux) \
		$(use_with skey) \
		$(use_with smartcard opensc) \
		$(use_with tcpd tcp-wrappers) \
		${myconf} \
		|| die "bad configure"
	emake || die "compile problem"
}

src_install() {
	emake install-nokeys DESTDIR="${D}" || die
	fperms 600 /etc/ssh/sshd_config
	dobin contrib/ssh-copy-id
	newinitd "${FILESDIR}"/sshd.rc6 sshd
	newconfd "${FILESDIR}"/sshd.confd sshd
	keepdir /var/empty
	keepdir /var/run

	newpamd "${FILESDIR}"/sshd.pam_include.2 sshd
	if use pam ; then
		sed -i \
			-e "/^#UsePAM /s:.*:UsePAM yes:" \
			-e "/^#PasswordAuthentication /s:.*:PasswordAuthentication no:" \
			-e "/^#PrintMotd /s:.*:PrintMotd no:" \
			-e "/^#PrintLastLog /s:.*:PrintLastLog no:" \
			"${ED}"/etc/ssh/sshd_config || die "sed of configuration file failed"
	fi

	# This instruction is from the HPN webpage,
	# Used for the server logging functionality
	if [[ -n ${HPN_PATCH} ]] && use hpn; then
		keepdir /var/empty/dev
	fi

	doman contrib/ssh-copy-id.1
	dodoc ChangeLog CREDITS OVERVIEW README* TODO sshd_config

	diropts -m 0700
	dodir /etc/skel/.ssh
}

src_test() {
	local t tests skipped failed passed shell
	tests="interop-tests compat-tests"
	skipped=""
	shell=$(getent passwd ${UID} | cut -d: -f7)
	if [[ ${shell} == */nologin ]] || [[ ${shell} == */false ]] ; then
		elog "Running the full OpenSSH testsuite"
		elog "requires a usable shell for the 'portage'"
		elog "user, so we will run a subset only."
		skipped="${skipped} tests"
	else
		tests="${tests} tests"
	fi
	for t in ${tests} ; do
		# Some tests read from stdin ...
		emake -k -j1 ${t} </dev/null \
			&& passed="${passed}${t} " \
			|| failed="${failed}${t} "
	done
	einfo "Passed tests: ${passed}"
	ewarn "Skipped tests: ${skipped}"
	if [[ -n ${failed} ]] ; then
		ewarn "Failed tests: ${failed}"
		die "Some tests failed: ${failed}"
	else
		einfo "Failed tests: ${failed}"
		return 0
	fi
}

pkg_postinst() {
	enewgroup sshd 22
	enewuser sshd 22 -1 /var/empty sshd

	# help fix broken perms caused by older ebuilds.
	# can probably cut this after the next stage release.
	chmod u+x "${EROOT}"/etc/skel/.ssh >& /dev/null

	ewarn "Remember to merge your config files in /etc/ssh/ and then"
	ewarn "reload sshd: '/etc/init.d/sshd reload'."
	if use pam ; then
		echo
		ewarn "Please be aware users need a valid shell in /etc/passwd"
		ewarn "in order to be allowed to login."
	fi
	if use pkcs11 ; then
		echo
		einfo "For PKCS#11 you should also emerge one of the askpass softwares"
		einfo "Example: net-misc/x11-ssh-askpass"
	fi
	# This instruction is from the HPN webpage,
	# Used for the server logging functionality
	if [[ -n ${HPN_PATCH} ]] && use hpn; then
		echo
		einfo "For the HPN server logging patch, you must ensure that"
		einfo "your syslog application also listens at /var/empty/dev/log."
	fi
}
