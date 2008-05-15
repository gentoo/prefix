# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openssh/openssh-5.0_p1-r1.ebuild,v 1.2 2008/05/11 13:12:32 ulm Exp $

EAPI="prefix"

inherit eutils flag-o-matic ccc multilib autotools pam

# Make it more portable between straight releases
# and _p? releases.
PARCH=${P/_/}

X509_PATCH="${PARCH}+x509-6.1.1.diff.gz"
#LDAP_PATCH="${PARCH/openssh-4.9/openssh-lpk-4.6}-0.3.9.patch"
HPN_PATCH="${PARCH}-hpn13v3.diff.gz"

DESCRIPTION="Port of OpenBSD's free SSH release"
HOMEPAGE="http://www.openssh.org/"
SRC_URI="mirror://openbsd/OpenSSH/portable/${PARCH}.tar.gz
	http://www.sxw.org.uk/computing/patches/openssh-5.0p1-gsskex-20080404.patch
	${LDAP_PATCH:+ldap? ( http://dev.inversepath.com/openssh-lpk/${LDAP_PATCH} )}
	${X509_PATCH:+X509? ( http://roumenpetrov.info/openssh/x509-6.1.1/${X509_PATCH} )}
	${HPN_PATCH:+hpn? ( http://www.psc.edu/networking/projects/hpn-ssh/${HPN_PATCH} )}"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static pam tcpd kerberos skey selinux X509 ldap smartcard hpn libedit X"

RDEPEND="pam? ( virtual/pam )
	kerberos? ( virtual/krb5 )
	selinux? ( >=sys-libs/libselinux-1.28 )
	skey? ( >=sys-auth/skey-1.1.5-r1 )
	ldap? ( net-nds/openldap )
	libedit? ( dev-libs/libedit )
	>=dev-libs/openssl-0.9.6d
	>=sys-libs/zlib-1.2.3
	smartcard? ( dev-libs/opensc )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	X? ( x11-apps/xauth )
	userland_GNU? ( sys-apps/shadow )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	virtual/os-headers
	sys-devel/autoconf"
PROVIDE="virtual/ssh"

S=${WORKDIR}/${PARCH}

pkg_setup() {
	# this sucks, but i'd rather have people unable to `emerge -u openssh`
	# than not be able to log in to their server any more
	maybe_fail() { [[ -z ${!2} ]] && use ${1} && echo ${1} ; }
	local fail="
		$(maybe_fail X509 X509_PATCH)
		$(maybe_fail ldap LDAP_PATCH)
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

	use X509 && epatch "${DISTDIR}"/${X509_PATCH} "${FILESDIR}"/${PN}-4.9_p1-x509-hpn-glue.patch
	use smartcard && epatch "${FILESDIR}"/openssh-3.9_p1-opensc.patch
	if ! use X509 ; then
		if [[ -n ${LDAP_PATCH} ]] && use ldap ; then
			epatch "${DISTDIR}"/${LDAP_PATCH} "${FILESDIR}"/${PN}-4.4_p1-ldap-hpn-glue.patch
			epatch "${FILESDIR}"/${P}-lpk-64bit.patch #210110
		fi
		epatch "${DISTDIR}"/openssh-5.0p1-gsskex-20080404.patch #115553 #216932
	else
		use ldap && ewarn "Sorry, X509 and ldap don't get along, disabling ldap"
		epatch "${FILESDIR}"/${PN}-4.7_p1-GSSAPI-dns.patch #165444 integrated into gsskex
	fi
	[[ -n ${HPN_PATCH} ]] && use hpn && epatch "${DISTDIR}"/${HPN_PATCH}
	epatch "${FILESDIR}"/${PN}-4.7p1-selinux.diff #191665

	sed -i "s:-lcrypto:$(pkg-config --libs openssl):" configure{,.ac} || die

	# Patch in Leopard's X forwarding magic
	[[ ${CHOST} == *-darwin9 ]] && epatch "${FILESDIR}"/${PN}-4.7_p1-darwin9-display.patch

	epatch "${FILESDIR}"/${PN}-4.7_p1-interix.patch
	epatch "${FILESDIR}"/${P}-root-uid.patch

	eautoreconf
}

src_compile() {
	addwrite /dev/ptmx
	addpredict /etc/skey/skeykeys #skey configure code triggers this

	local myconf=""
	if use static ; then
		append-ldflags -static
		use pam && ewarn "Disabling pam support becuse of static flag"
		myconf="${myconf} --without-pam"
	else
		myconf="${myconf} $(use_with pam)"
	fi

	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	econf \
		--with-ldflags="${LDFLAGS}" \
		--disable-strip \
		--sysconfdir="${EPREFIX}"/etc/ssh \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/misc \
		--datadir="${EPREFIX}"/usr/share/openssh \
		--disable-suid-ssh \
		--with-privsep-path="${EPREFIX}"/var/empty \
		--with-pid-dir="${EPREFIX}"/var/run \
		--with-privsep-user=sshd \
		--with-md5-passwords \
		--with-ssl-engine \
		$(use_with ldap) \
		$(use_with libedit) \
		$(use_with kerberos kerberos5 /usr) \
		$(use_with tcpd tcp-wrappers) \
		$(use_with selinux) \
		$(use_with skey) \
		$(use_with smartcard opensc) \
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

	newpamd "${FILESDIR}"/sshd.pam_include.1 sshd
	use pam \
		&& dosed "/^#UsePAM /s:.*:UsePAM yes:" /etc/ssh/sshd_config \
		&& dosed "/^#PasswordAuthentication /s:.*:PasswordAuthentication no:" /etc/ssh/sshd_config

	doman contrib/ssh-copy-id.1
	dodoc ChangeLog CREDITS OVERVIEW README* TODO sshd_config

	diropts -m 0700
	dodir /etc/skel/.ssh
}

pkg_postinst() {
	enewgroup sshd 22
	enewuser sshd 22 -1 /var/empty sshd

	# help fix broken perms caused by older ebuilds.
	# can probably cut this after the next stage release.
	chmod u+x "${EROOT}"/etc/skel/.ssh >& /dev/null

	ewarn "Remember to merge your config files in /etc/ssh/ and then"
	ewarn "restart sshd: '/etc/init.d/sshd restart'."
	if use pam ; then
		echo
		ewarn "Please be aware users need a valid shell in /etc/passwd"
		ewarn "in order to be allowed to login."
	fi
}
