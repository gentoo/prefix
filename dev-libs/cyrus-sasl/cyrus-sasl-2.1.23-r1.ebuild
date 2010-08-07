# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/cyrus-sasl/cyrus-sasl-2.1.23-r1.ebuild,v 1.12 2010/06/17 20:12:32 patrick Exp $

inherit eutils flag-o-matic multilib autotools pam java-pkg-opt-2

ntlm_patch="${P}-ntlm_impl-spnego.patch.gz"
SASLAUTHD_CONF_VER="2.1.21"

DESCRIPTION="The Cyrus SASL (Simple Authentication and Security Layer)."
HOMEPAGE="http://asg.web.cmu.edu/sasl/"
SRC_URI="ftp://ftp.andrew.cmu.edu/pub/cyrus-mail/${P}.tar.gz
	ntlm_unsupported_patch? ( mirror://gentoo/${ntlm_patch} )"

LICENSE="as-is"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="authdaemond berkdb crypt gdbm kerberos ldap mysql ntlm_unsupported_patch pam postgres sample sqlite srp ssl urandom"

RDEPEND="authdaemond? ( || ( >=net-mail/courier-imap-3.0.7 >=mail-mta/courier-0.46 ) )
	berkdb? ( >=sys-libs/db-3.2 )
	gdbm? ( >=sys-libs/gdbm-1.8.0 )
	kerberos? ( virtual/krb5 )
	ldap? ( >=net-nds/openldap-2.0.25 )
	mysql? ( virtual/mysql )
	ntlm_unsupported_patch? ( >=net-fs/samba-3.0.9 )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql-base )
	sqlite? ( dev-db/sqlite )
	ssl? ( >=dev-libs/openssl-0.9.6d )"
DEPEND="${RDEPEND}
	java? ( >=virtual/jdk-1.4 )"
RDEPEND="${RDEPEND} java? ( >=virtual/jre-1.4 )"

pkg_setup() {
	if use gdbm && use berkdb ; then
		echo
		ewarn "You have both the 'gdbm' and 'berkdb' USE flags enabled."
		ewarn "Will default to GNU DB as your SASLdb database backend."
		ewarn "If you want to build with BerkeleyDB support, hit Control-C now,"
		ewarn "change your USE flags -gdbm and emerge again."
		echo
		ewarn "Waiting 10 seconds before starting ..."
		ewarn "(Control-C to abort) ..."
		epause 10
	fi
	java-pkg-opt-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix default port name for rimap auth mechanism.
	sed -e '/define DEFAULT_REMOTE_SERVICE/s:imap:imap2:' \
		-i saslauthd/auth_rimap.c || die "sed failed"

	# UNSUPPORTED ntlm patch #81342
	use ntlm_unsupported_patch && epatch "${DISTDIR}/${ntlm_patch}"

	epatch "${FILESDIR}"/${PN}-2.1.17-pgsql-include.patch
	epatch "${FILESDIR}"/${PN}-2.1.22-as-needed.patch
	use crypt && epatch "${FILESDIR}"/${PN}-2.1.19-checkpw.c.patch #45181
	epatch "${FILESDIR}"/${PN}-2.1.22-crypt.patch #152544
	epatch "${FILESDIR}"/${PN}-2.1.22-qa.patch
	epatch "${FILESDIR}"/${PN}-2.1.22-db4.patch #192753
	epatch "${FILESDIR}/${PN}-2.1.22-gcc44.patch" #248738
	epatch "${FILESDIR}"/${P}-authd-fix.patch

	# Upstream doesn't even honor their own configure options... grumble
	sed -i '/^sasldir =/s:=.*:= $(plugindir):' \
		"${S}"/plugins/Makefile.{am,in} || die "sed failed"

	# make sure to use common plugin ldflags
	sed -i '/_la_LDFLAGS = /s:=:= $(AM_LDFLAGS) :' plugins/Makefile.am || die

	# Recreate configure.
	rm -f "${S}/config/libtool.m4" || die "rm libtool.m4 failed"
	AT_M4DIR="${S}/cmulocal ${S}/config" eautoreconf
}

src_compile() {
	# Fix QA issues.
	append-flags -fno-strict-aliasing
	if [[ ${CHOST} == *-solaris* ]] ; then
		# getpassphrase is defined in /usr/include/stdlib.h
		append-cppflags -DHAVE_GETPASSPHRASE
	else
		# this horrendously breaks things on Solaris
		append-cppflags -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -DLDAP_DEPRECATED
	fi

	# Java support.
	use java && export JAVAC="${JAVAC} ${JAVACFLAGS}"

	local myconf

	# Add authdaemond support (bug #56523).
	if use authdaemond ; then
		myconf="${myconf} --with-authdaemond=${EPREFIX}/var/lib/courier/authdaemon/socket"
	fi

	# Fix for bug #59634.
	if ! use ssl ; then
		myconf="${myconf} --without-des"
	fi

	if use mysql || use postgres || use sqlite ; then
		myconf="${myconf} --enable-sql"
	else
		myconf="${myconf} --disable-sql"
	fi

	# Default to GDBM if both 'gdbm' and 'berkdb' are present.
	if use gdbm ; then
		einfo "Building with GNU DB as database backend for your SASLdb"
		myconf="${myconf} --with-dblib=gdbm"
	elif use berkdb ; then
		einfo "Building with BerkeleyDB as database backend for your SASLdb"
		myconf="${myconf} --with-dblib=berkeley"
	else
		einfo "Building without SASLdb support"
		myconf="${myconf} --with-dblib=none"
	fi

	# Use /dev/urandom instead of /dev/random (bug #46038).
	use urandom && myconf="${myconf} --with-devrandom=/dev/urandom"

	# Don't even try to build a framework if on OSX
	myconf="${myconf} --disable-macos-framework"

	econf \
		--enable-login \
		--enable-ntlm \
		--enable-auth-sasldb \
		--disable-krb4 \
		--disable-otp \
		--with-saslauthd="${EPREFIX}"/var/lib/sasl2 \
		--with-pwcheck="${EPREFIX}"/var/lib/sasl2 \
		--with-configdir="${EPREFIX}"/etc/sasl2 \
		--with-plugindir="${EPREFIX}"/usr/$(get_libdir)/sasl2 \
		--with-dbpath="${EPREFIX}"/etc/sasl2/sasldb2 \
		$(use_with ssl openssl) \
		$(use_with pam) \
		$(use_with ldap) \
		$(use_enable ldap ldapdb) \
		$(use_enable sample) \
		$(use_enable kerberos gssapi) \
		$(use_enable java) \
		$(use_with java javahome ${JAVA_HOME}) \
		$(use_with mysql) \
		$(use_with postgres pgsql $(pg_config --libdir)) \
		$(use_with sqlite) \
		$(use_enable srp) \
		${myconf} || die "econf failed"

	# We force -j1 for bug #110066.
	emake -j1 || die "emake failed"

	# Default location for java classes breaks OpenOffice (bug #60769).
	# Thanks to axxo@gentoo.org for the solution.
	cd "${S}"
	if use java ; then
		jar -cvf ${PN}.jar -C java $(find java -name "*.class")
	fi

	# Add testsaslauthd (bug #58768).
	cd "${S}/saslauthd"
	emake testsaslauthd || die "emake testsaslauthd failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	keepdir /var/lib/sasl2 /etc/sasl2

	# Install everything necessary so users can build sample
	# client/server (bug #64733).
	if use sample ; then
		insinto /usr/share/${PN}-2/examples
		doins aclocal.m4 config.h config.status configure.in
		dosym /usr/include/sasl /usr/share/${PN}-2/examples/include
		exeinto /usr/share/${PN}-2/examples
		doexe libtool
		insinto /usr/share/${PN}-2/examples/sample
		doins sample/*.{c,h} sample/*Makefile*
		insinto /usr/share/${PN}-2/examples/sample/.deps
		doins sample/.deps/*
		dodir /usr/share/${PN}-2/examples/lib
		dosym /usr/$(get_libdir)/libsasl2.la /usr/share/${PN}-2/examples/lib/libsasl2.la
		dodir /usr/share/${PN}-2/examples/lib/.libs
		dosym /usr/$(get_libdir)/libsasl2.so /usr/share/${PN}-2/examples/lib/.libs/libsasl2.so
	fi

	# Default location for java classes breaks OpenOffice (bug #60769).
	if use java ; then
		java-pkg_dojar ${PN}.jar
		java-pkg_regso "${ED}/usr/$(get_libdir)/libjavasasl$(get_libname)"
		# hackish, don't wanna dig through makefile
		rm -Rf "${ED}/usr/$(get_libdir)/java"
		docinto "java"
		dodoc "${S}/java/README" "${FILESDIR}/java.README.gentoo" "${S}"/java/doc/*
		dodir "/usr/share/doc/${PF}/java/Test"
		insinto "/usr/share/doc/${PF}/java/Test"
		doins "${S}"/java/Test/*.java || die "Failed to copy java files to /usr/share/doc/${PF}/java/Test"
	fi

	docinto ""
	dodoc AUTHORS ChangeLog NEWS README doc/TODO doc/*.txt
	newdoc pwcheck/README README.pwcheck
	dohtml doc/*.html

	docinto "saslauthd"
	dodoc saslauthd/{AUTHORS,ChangeLog,LDAP_SASLAUTHD,NEWS,README}

	newpamd "${FILESDIR}/saslauthd.pam-include" saslauthd || die "Failed to install saslauthd to /etc/pam.d"

	newinitd "${FILESDIR}/pwcheck.rc6" pwcheck || die "Failed to install pwcheck to /etc/init.d"

	newinitd "${FILESDIR}/saslauthd2.rc6" saslauthd || die "Failed to install saslauthd to /etc/init.d"
	newconfd "${FILESDIR}/saslauthd-${SASLAUTHD_CONF_VER}.conf" saslauthd || die "Failed to install saslauthd to /etc/conf.d"

	exeinto /usr/sbin
	newexe "${S}/saslauthd/testsaslauthd" testsaslauthd || die "Failed to install testsaslauthd"
}

pkg_postinst () {
	# Generate an empty sasldb2 with correct permissions.
	if ( use berkdb || use gdbm ) && [[ ! -f "${EROOT}/etc/sasl2/sasldb2" ]] ; then
		einfo "Generating an empty sasldb2 with correct permissions ..."
		echo "p" | "${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -p login \
			|| die "Failed to generate sasldb2"
		"${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -d login \
			|| die "Failed to delete temp user"
		chown root:mail "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chown ${EROOT}/etc/sasl2/sasldb2"
		chmod 0640 "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chmod ${EROOT}/etc/sasl2/sasldb2"
	fi

	if use sample ; then
		elog "You have chosen to install sources for the example client and server."
		elog "To build these, please type:"
		elog "\tcd /usr/share/${PN}-2/examples/sample && make"
	fi

	if use authdaemond ; then
		elog "You need to add a user running a service using Courier's"
		elog "authdaemon to the 'mail' group. For example, do:"
		elog "	gpasswd -a postfix mail"
		elog "to add the 'postfix' user to the 'mail' group."
	fi
}
