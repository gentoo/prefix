# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/www-servers/lighttpd/lighttpd-1.4.19-r2.ebuild,v 1.7 2008/04/20 21:13:10 vapier Exp $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest
inherit eutils autotools depend.php

DESCRIPTION="Lightweight high-performance web server"
HOMEPAGE="http://www.lighttpd.net/"
SRC_URI="http://www.lighttpd.net/download/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="bzip2 doc fam fastcgi gdbm ipv6 ldap lua minimal memcache mysql pcre php rrdtool ssl test webdav xattr"

RDEPEND=">=sys-libs/zlib-1.1
	bzip2?    ( app-arch/bzip2 )
	fam?      ( virtual/fam )
	gdbm?     ( sys-libs/gdbm )
	ldap?     ( >=net-nds/openldap-2.1.26 )
	lua?      ( >=dev-lang/lua-5.1 )
	memcache? ( dev-libs/libmemcache )
	mysql?    ( >=virtual/mysql-4.0 )
	pcre?     ( >=dev-libs/libpcre-3.1 )
	php?      ( virtual/httpd-php )
	rrdtool? ( net-analyzer/rrdtool )
	ssl?    ( >=dev-libs/openssl-0.9.7 )
	webdav? (
		dev-libs/libxml2
		>=dev-db/sqlite-3
		sys-fs/e2fsprogs
	)
	xattr? ( kernel_linux? ( sys-apps/attr ) )"

DEPEND="${RDEPEND}
	doc?  ( dev-python/docutils )
	test? (
		virtual/perl-Test-Harness
		dev-libs/fcgi
	)"

# update certain parts of lighttpd.conf based on conditionals
update_config() {
	local config="/etc/lighttpd/lighttpd.conf"

	# enable php/mod_fastcgi settings
	use php && \
		dosed 's|#.*\(include.*fastcgi.*$\)|\1|' ${config}

	# enable stat() caching
	use fam && \
		dosed 's|#\(.*stat-cache.*$\)|\1|' ${config}
}

# remove non-essential stuff (for USE=minimal)
remove_non_essential() {
	local libdir="${ED}/usr/$(get_libdir)/${PN}"

	# text docs
	use doc || rm -fr "${ED}"/usr/share/doc/${PF}/txt

	# non-essential modules
	rm -f \
		${libdir}/mod_{compress,evhost,expire,proxy,scgi,secdownload,simple_vhost,status,setenv,trigger*,usertrack}.*

	# allow users to keep some based on USE flags
	use pcre    || rm -f ${libdir}/mod_{ssi,re{direct,write}}.*
	use webdav  || rm -f ${libdir}/mod_webdav.*
	use mysql   || rm -f ${libdir}/mod_mysql_vhost.*
	use lua     || rm -f ${libdir}/mod_{cml,magnet}.*
	use rrdtool || rm -f ${libdir}/mod_rrdtool.*

	if ! use fastcgi ; then
		rm -f ${libdir}/mod_fastcgi.* "${ED}"/usr/bin/spawn-fcgi \
			"${ED}"/usr/share/man/man1/spawn-fcgi.*
	fi
}

pkg_setup() {
	if ! use pcre ; then
		ewarn "It is highly recommended that you build ${PN}"
		ewarn "with perl regular expressions support via USE=pcre."
		ewarn "Otherwise you lose support for some core options such"
		ewarn "as conditionals and modules such as mod_re{write,direct}"
		ewarn "and mod_ssi."
		ebeep 5
	fi

	use php && require_php_with_use cgi

	enewgroup lighttpd
	enewuser lighttpd -1 -1 /var/www/localhost/htdocs lighttpd
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	EPATCH_SUFFIX="diff" EPATCH_OPTS="-l" epatch "${FILESDIR}"/"${PVR}" || die "Patching failed!"

	eautoreconf || die

	# dev-python/docutils installs rst2html.py not rst2html
	sed -i -e 's|\(rst2html\)|\1.py|g' doc/Makefile.in || \
		die "sed doc/Makefile.in failed"

	# fix typo
	sed -i -e 's|\(output_content\)_\(type\)|\1\2|' doc/cml.txt || \
		die "sed doc/cml.txt failed"
}

src_compile() {
	econf --libdir="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		--enable-lfs \
		$(use_enable ipv6) \
		$(use_with bzip2) \
		$(use_with fam) \
		$(use_with gdbm) \
		$(use_with lua) \
		$(use_with ldap) \
		$(use_with memcache) \
		$(use_with mysql) \
		$(use_with pcre) \
		$(use_with ssl openssl) \
		$(use_with webdav webdav-props) \
		$(use_with webdav webdav-locks) \
		$(use_with xattr attr) \
		|| die "econf failed"

	emake || die "emake failed"

	if use doc ; then
		einfo "Building HTML documentation"
		cd doc
		emake html || die "failed to build HTML documentation"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# init script stuff
	newinitd "${FILESDIR}"/lighttpd.initd-1.4.13-r3 lighttpd || die
	newconfd "${FILESDIR}"/lighttpd.confd lighttpd || die
	use fam && has_version app-admin/fam && \
		sed -i 's/after famd/need famd/g' "${ED}"/etc/init.d/lighttpd

	if use php || use fastcgi ; then
		newinitd "${FILESDIR}"/spawn-fcgi.initd spawn-fcgi || die
		newconfd "${FILESDIR}"/spawn-fcgi.confd spawn-fcgi || die
	fi

	# configs
	insinto /etc/lighttpd
	doins "${FILESDIR}"/conf/lighttpd.conf
	doins "${FILESDIR}"/conf/mime-types.conf
	doins "${FILESDIR}"/conf/mod_cgi.conf
	newins "${FILESDIR}"/conf/mod_fastcgi.conf-1.4.13-r2 mod_fastcgi.conf
	# Secure directory for fastcgi sockets
	keepdir /var/run/lighttpd/
	fperms 0750 /var/run/lighttpd/
	fowners lighttpd:lighttpd /var/run/lighttpd/

	# update lighttpd.conf directives based on conditionals
	update_config

	# docs
	dodoc AUTHORS README NEWS ChangeLog doc/*.sh
	newdoc doc/lighttpd.conf lighttpd.conf.distrib

	use doc && dohtml -r doc/*

	docinto txt
	dodoc doc/*.txt

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/lighttpd.logrotate lighttpd || die

	keepdir /var/l{ib,og}/lighttpd /var/www/localhost/htdocs
	fowners lighttpd:lighttpd /var/l{ib,og}/lighttpd
	fperms 0750 /var/l{ib,og}/lighttpd

	use minimal && remove_non_essential
}

pkg_postinst () {
	echo
	if [[ -f ${EROOT}etc/conf.d/spawn-fcgi.conf ]] ; then
		einfo "spawn-fcgi is now included with lighttpd"
		einfo "spawn-fcgi's init script configuration is now located"
		einfo "at /etc/conf.d/spawn-fcgi."
		echo
	fi

	if [[ -f ${EROOT}etc/lighttpd.conf ]] ; then
		ewarn "As of lighttpd-1.4.1, Gentoo has a customized configuration,"
		ewarn "which is now located in /etc/lighttpd.  Please migrate your"
		ewarn "existing configuration."
		ebeep 5
	fi

	if use fam ; then
		einfo "Remember to re-emerge lighttpd should you switch from"
		einfo "app-admin/famd to app-admin/gamin or vice versa."
	fi
	echo
}
