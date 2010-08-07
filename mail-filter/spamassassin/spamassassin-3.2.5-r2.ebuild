# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-filter/spamassassin/spamassassin-3.2.5-r2.ebuild,v 1.7 2010/06/24 08:28:09 angelos Exp $

inherit perl-module eutils

MY_P=Mail-SpamAssassin-${PV//_/-}
S=${WORKDIR}/${MY_P}
DESCRIPTION="SpamAssassin is an extensible email filter which is used to identify spam."
HOMEPAGE="http://spamassassin.apache.org/"
SRC_URI="http://archive.apache.org/dist/spamassassin/source/${MY_P}.tar.bz2 mirror://gentoo/${MY_P}.tar.bz2"

SRC_TEST="do"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="berkdb qmail ssl doc ldap mysql postgres sqlite tools ipv6"

DEPEND=">=dev-lang/perl-5.8.2-r1
	virtual/perl-MIME-Base64
	>=virtual/perl-PodParser-1.32
	virtual/perl-Storable
	virtual/perl-Time-HiRes
	>=dev-perl/HTML-Parser-3.43
	>=dev-perl/Net-DNS-0.53
	dev-perl/Digest-SHA1
	dev-perl/libwww-perl
	>=virtual/perl-Archive-Tar-1.26
	app-crypt/gnupg
	>=virtual/perl-IO-Zlib-1.04
	>=dev-util/re2c-0.12.0
	ssl? (
		dev-perl/IO-Socket-SSL
		dev-libs/openssl
	)
	berkdb? (
		virtual/perl-DB_File
	)
	ldap? ( dev-perl/perl-ldap )
	mysql? (
		dev-perl/DBI
		dev-perl/DBD-mysql
	)
	postgres? (
		dev-perl/DBI
		dev-perl/DBD-Pg
	)
	sqlite? (
		dev-perl/DBI
		dev-perl/DBD-SQLite
	)

	ipv6? (
		dev-perl/IO-Socket-INET6
	)"

PATCHES=( "${FILESDIR}/${PN}-3.2.5-DESTDIR.patch"
	"${FILESDIR}/FH_DATE_PAST_20XX.patch" )

src_compile() {
	# - Set SYSCONFDIR explicitly so we can't get bitten by bug 48205 again
	#   (just to be sure, nobody knows how it could happen in the first place).
	myconf="SYSCONFDIR=${EPREFIX}/etc DATADIR=${EPREFIX}/usr/share/spamassassin"

	# If ssl is enabled, spamc can be built with ssl support
	if use ssl; then
		myconf="${myconf} ENABLE_SSL=yes"
	else
		myconf="${myconf} ENABLE_SSL=no"
	fi

	# Set the path to the Perl executable explictly.  This will be used to
	# create the initial sharpbang line in the scripts and might cause
	# a versioned app name end in there, see
	# <http://bugs.gentoo.org/show_bug.cgi?id=62276>
	myconf="${myconf} PERL_BIN=${EPREFIX}/usr/bin/perl"

	# If you are going to enable taint mode, make sure that the bug where
	# spamd doesn't start when the PATH contains . is addressed, and make
	# sure you deal with versions of razor <2.36-r1 not being taint-safe.
	# <http://bugzilla.spamassassin.org/show_bug.cgi?id=2511> and
	# <http://spamassassin.org/released/Razor2.patch>.
	myconf="${myconf} PERL_TAINT=no"

	# No settings needed for 'make all'.
	mymake=""

	# Neither for 'make install'.
	myinst=""

	# Add Gentoo tag to make it easier for the upstream devs to spot
	# possible modifications or patches.
	version_tag="g${PV:6}${PR}"
	version_str="${PV//_/-}-${version_tag}"

	# Create the Gentoo config file before Makefile.PL is called so it
	# is copied later on.
	echo "version_tag ${version_tag}" > rules/11_gentoo.cf

	# Setting the following env var ensures that no questions are asked.
	export PERL_MM_USE_DEFAULT=1
	perl-module_src_prep
	# Run the autoconf stuff now, just to make the build sequence look more
	# familiar to the user :)  Plus feeding the VERSION_STRING skips some
	# calls to Perl.
	make spamc/Makefile VERSION_STRING="${version_str}"

	# Now compile all the stuff selected.
	perl-module_src_compile
	if use qmail; then
		make spamc/qmail-spamc || die building qmail-spamc failed
	fi

	# Remove the MANIFEST files as they aren't docu files
	rm -f MANIFEST*

	use doc && make text_html_doc
}

src_test() {
	perl-module_src_test
}

src_install () {
	perl-module_src_install

	# Create the stub dir used by sa-update and friends
	dodir /var/lib/spamassassin

	# Move spamd to sbin where it belongs.
	dodir /usr/sbin
	mv "${ED}"/usr/bin/spamd "${ED}"/usr/sbin/spamd  || die

	use qmail && dobin spamc/qmail-spamc

	dosym /etc/mail/spamassassin /etc/spamassassin

	# Disable plugin by default
	sed -i -e 's/^loadplugin/\#loadplugin/g' "${ED}"/etc/mail/spamassassin/init.pre

	# Add the init and config scripts.
	newinitd "${FILESDIR}"/3.0.0-spamd.init spamd
	newconfd "${FILESDIR}"/3.0.0-spamd.conf spamd

	if use doc; then
		dodoc NOTICE TRADEMARK CREDITS INSTALL INSTALL.VMS UPGRADE USAGE \
		sql/README.bayes sql/README.awl procmailrc.example sample-nonspam.txt \
		sample-spam.txt spamassassin.spec spamd/PROTOCOL spamd/README.vpopmail \
		spamd-apache2/README.apache

		# Rename some docu files so they don't clash with others
		newdoc spamd/README README.spamd
		newdoc sql/README README.sql
		newdoc ldap/README README.ldap
		use qmail && newdoc spamc/README.qmail README.qmail

		dohtml doc/*.html
		docinto sql
		dodoc sql/*.sql
	fi

	# Install provided tools. See bug 108168
	if use tools; then
		docinto tools
		dodoc tools/*
	fi

	cp "${FILESDIR}"/secrets.cf "${ED}"/etc/mail/spamassassin/secrets.cf.example
	fperms 0400 /etc/mail/spamassassin/secrets.cf.example
	echo "">>${ED}/etc/mail/spamassassin/local.cf.example
	echo "# Sensitive data, such as database connection info, should">>${ED}/etc/mail/spamassassin/local.cf.example
	echo "# be stored in /etc/mail/spamassassin/secrets.cf with">>${ED}/etc/mail/spamassassin/local.cf.example
	echo "# appropriate permissions">>${ED}/etc/mail/spamassassin/local.cf.example
}

pkg_postinst() {
	perl-module_pkg_postinst

	if ! has_version "perl-core/DB_File"; then
		einfo "The Bayes backend requires the Berkeley DB to store its data. You"
		einfo "need to emerge perl-core/DB_File or USE=berkdb to make it available."
	fi

	if has_version "mail-filter/razor"; then
		if ! has_version ">=mail-filter/razor-2.61"; then
				ewarn "You have $(best_version mail-filter/razor) installed but SpamAssassin"
				if has_version "<mail-filter/razor-2.40"; then
					ewarn "requires at least version 2.40, version 2.61 or later is recommended."
				else
					ewarn "recommends at least version 2.61."
				fi
		fi
	fi

	if use doc; then
		einfo
		einfo "Please read the file INSTALL in"
		einfo "  /usr/share/doc/${PF}/"
		einfo "to find out which optional modules you need to install to enable"
		einfo "additional features which depend on them."
		einfo
		einfo "If upgraded from 2.x, please read the file UPGRADE in"
		einfo "  /usr/share/doc/${PF}/"
		einfo
	fi

	ewarn
	ewarn "spamd is not designed to listen to an untrusted network"
	ewarn "and is vulnerable to DoS attacks (and eternal doom) if"
	ewarn "configured to do so"
	ewarn
	elog "If you plan on using the -u flag to spamd, please read the notes"
	elog "in /etc/conf.d/spamd regarding the location of the pid file."

	einfo
	einfo "If you build ${PN} with optional dependancy support,"
	einfo "you can enable them in /etc/mail/spamassassin/init.pre"
	einfo

	if has_version '>=dev-lang/perl-5.8.8'; then
		elog "A note from the SA developers:"
		elog "Perl 5.8 now uses Unicode internally by default, which causes trouble for"
		elog "SpamAssassin (and almost all other reasonably complex pieces of perl"
		elog "code!)."
		elog ""
		elog "We've worked around this in most places, as far as we know, but there may"
		elog "still be some issues.  In addition, there is a speed hit, which it would"
		elog "be nice to avoid."
		elog ""
		elog "Setting the LANG environment variable before any invocation of"
		elog "SpamAssassin sometimes seems to help fix it, like so:"
		elog ""
		elog "  export LANG=en_US"
		elog ""
		elog "Notably, the LANG setting must not include \"utf8\".   However, some folks"
		elog "have reported that this makes no difference. ;)"
	fi
	einfo
	if ! has_version 'dev-perl/Mail-SPF-Query'; then
		elog "For spf support, please emerge dev-perl/Mail-SPF-Query"
	fi
	if ! has_version 'mail-filter/dcc'; then
		elog "For dcc support, please emerge mail-filter/dcc"
	fi
	if ! has_version 'dev-python/pyzor'; then
		elog "For pyzor support, please emerge dev-python/pyzor"
	fi
	if ! has_version 'mail-filter/razor'; then
		elog "For razor support, please emerge mail-filter/razor"
	fi
	einfo
	elog "For addtional functionality, you may wish to emerge:"
	elog "dev-perl/IP-Country       dev-perl/Net-Ident "
	elog "dev-perl/Mail-DKIM"

}
