# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-mta/ssmtp/ssmtp-2.61-r2.ebuild,v 1.11 2006/12/04 19:25:36 eroyf Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Extremely simple MTA to get mail off the system to a Mailhub"
HOMEPAGE="ftp://ftp.debian.org/debian/pool/main/s/ssmtp/"
SRC_URI="mirror://debian/pool/main/s/ssmtp/${P/-/_}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="ssl ipv6 md5sum mailwrapper"

DEPEND="virtual/libc
	ssl? ( dev-libs/openssl )"
RDEPEND="mailwrapper? ( >=net-mail/mailwrapper-0.2 )
	!mailwrapper? ( !virtual/mta )
	net-mail/mailbase
	ssl? ( dev-libs/openssl )"
PROVIDE="virtual/mta"

S=${WORKDIR}/ssmtp-2.61

src_unpack() {
	unpack "${A}" ; cd "${S}"

	epatch "${FILESDIR}"/ssmtp-2.61-bug127592.patch
	epatch "${FILESDIR}"/ssmtp-2.61-darwin7.patch

	# Respect LDFLAGS (bug #152197)
	sed -i -e 's:$(CC) -o:$(CC) @LDFLAGS@ -o:' Makefile.in
}

src_compile() {
	tc-export CC LD

	[[ ${USERLAND} == "Darwin" ]] && append-ldflags -undefined dynamic_lookup
	econf \
		--sysconfdir="${EPREFIX}"/etc/ssmtp \
		$(use_enable ssl) \
		$(use_enable ipv6 inet6) \
		$(use_enable md5sum md5auth) \
		|| die
	make clean || die
	make etcdir="${EPREFIX}"/etc || die
}

src_install() {
	dodir /usr/bin /usr/sbin /usr/lib
	dosbin ssmtp || die
	fperms 755 /usr/sbin/ssmtp
	dosym /usr/sbin/sendmail /usr/bin/mailq
	dosym /usr/sbin/sendmail /usr/bin/newaliases
	# Removed symlink due to conflict with mailx
	# See bug #7448
	#dosym /usr/sbin/ssmtp /usr/bin/mail
	#The sendmail symlink is now handled by mailwrapper if used
	use mailwrapper || \
		dosym /usr/sbin/ssmtp /usr/sbin/sendmail
	dosym /usr/sbin/sendmail /usr/lib/sendmail
	doman ssmtp.8
	#removing the sendmail.8 symlink to support multiple installed mtas.
	#dosym /usr/share/man/man8/ssmtp.8 /usr/share/man/man8/sendmail.8
	dodoc INSTALL README TLS CHANGELOG_OLD
	# This subdir has apparently disappeared in a later release:
	# dodoc debian/{README.debian,changelog}
	newdoc ssmtp.lsm DESC
	insinto /etc/ssmtp
	doins ssmtp.conf revaliases
	if use mailwrapper
	then
		insinto /etc/mail
		doins ${FILESDIR}/mailer.conf
	fi

	# Set up config file
	# See bug #22658
	#local conffile="/etc/ssmtp/ssmtp.conf"
	#local hostname=`hostname -f`
	#local domainname=`hostname -d`
	#mv ${conffile} ${conffile}.orig
	#sed -e "s:rewriteDomain=:rewriteDomain=${domainname}:g" \
	#        -e "s:_HOSTNAME_:${hostname}:" \
	#        -e "s:^mailhub=mail:mailhub=mail.${domainname}:g" \
	#        ${conffile}.orig > ${conffile}.pre
	#if use ssl;
	#then
	#        sed -e "s:^#UseTLS=YES:UseTLS=YES:g" \
	#                ${conffile}.pre > ${conffile}
	#        mv ${conffile}.pre ${conffile}.orig
	#else
	#        mv ${conffile}.pre ${conffile}
	#fi

	# set up config file, v2. Bug 47562
	local conffile="${ED}/etc/ssmtp/ssmtp.conf"
	mv "${conffile}" "${conffile}.orig"
	# Sorry about the weird indentation, I couldn't figure out a cleverer way
	# to do this without having horribly >80 char lines.
	sed -e "s:^hostname=:\n# Gentoo bug #47562\\
# Commenting the following line will force ssmtp to figure\\
# out the hostname itself.\n\\
# hostname=:" \
		"${conffile}.orig" > "${conffile}" \
		|| die "sed failed"
}

pkg_postinst() {
	if ! use mailwrapper && [[ -e /etc/mailer.conf ]]
	then
		einfo
		einfo "Since you emerged ssmtp w/o mailwrapper in USE,"
		einfo "you probably want to 'emerge -C mailwrapper' now."
		einfo
	fi
}
