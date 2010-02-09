# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/nginx/nginx-0.8.33.ebuild,v 1.1 2010/02/02 08:39:21 djc Exp $

inherit eutils ssl-cert toolchain-funcs perl-module

DESCRIPTION="Robust, small and high performance http and reverse proxy server"

HOMEPAGE="http://nginx.net/"
SRC_URI="http://sysoev.ru/nginx/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="addition aio debug fastcgi flv imap ipv6 pcre perl pop random-index realip securelink smtp ssl static-gzip status sub webdav zlib"

DEPEND="dev-lang/perl
	dev-libs/openssl
	pcre? ( >=dev-libs/libpcre-4.2 )
	zlib? ( sys-libs/zlib )
	perl? ( >=dev-lang/perl-5.8 )"

pkg_setup() {
	ebegin "Creating nginx user and group"
	enewgroup ${PN}
	enewuser ${PN} -1 -1 -1 ${PN}
	eend ${?}
	if use ipv6; then
		ewarn "Note that ipv6 support in nginx is still experimental."
		ewarn "Be sure to read comments on gentoo bug #274614"
		ewarn "http://bugs.gentoo.org/show_bug.cgi?id=274614"
	fi
}

src_unpack() {
	unpack ${A}
	sed -i 's/ make/ \\$(MAKE)/' "${S}"/auto/lib/perl/make || die
}

src_compile() {
	local myconf

	# threads support is broken atm.
	#
	# if use threads; then
	# 	einfo
	# 	ewarn "threads support is experimental at the moment"
	# 	ewarn "do not use it on production systems - you've been warned"
	# 	einfo
	# 	myconf="${myconf} --with-threads"
	# fi

	use addition && myconf="${myconf} --with-http_addition_module"
	use aio		&& myconf="${myconf} --with-file-aio"
	use ipv6	&& myconf="${myconf} --with-ipv6"
	use fastcgi	|| myconf="${myconf} --without-http_fastcgi_module"
	use fastcgi	&& myconf="${myconf} --with-http_realip_module"
	use flv		&& myconf="${myconf} --with-http_flv_module"
	use zlib	|| myconf="${myconf} --without-http_gzip_module"
	use pcre	|| {
		myconf="${myconf} --without-pcre --without-http_rewrite_module"
	}
	use debug	&& myconf="${myconf} --with-debug"
	use ssl		&& myconf="${myconf} --with-http_ssl_module"
	use perl	&& myconf="${myconf} --with-http_perl_module"
	use status	&& myconf="${myconf} --with-http_stub_status_module"
	use webdav	&& myconf="${myconf} --with-http_dav_module"
	use sub		&& myconf="${myconf} --with-http_sub_module"
	use realip	&& myconf="${myconf} --with-http_realip_module"
	use static-gzip		&& myconf="${myconf} --with-http_gzip_static_module"
	use random-index	&& myconf="${myconf} --with-http_random_index_module"
	use securelink		&& myconf="${myconf} --with-http_secure_link_module"

	if use smtp || use pop || use imap; then
		myconf="${myconf} --with-mail"
		use ssl && myconf="${myconf} --with-mail_ssl_module"
	fi
	use imap || myconf="${myconf} --without-mail_imap_module"
	use pop || myconf="${myconf} --without-mail_pop3_module"
	use smtp || myconf="${myconf} --without-mail_smtp_module"

	tc-export CC
	./configure \
		--prefix="${EPREFIX}"/usr \
		--with-cc-opt="-I${EROOT}/usr/include" \
		--with-ld-opt="-L${EROOT}/usr/lib" \
		--conf-path="${EPREFIX}"/etc/${PN}/${PN}.conf \
		--http-log-path="${EPREFIX}"/var/log/${PN}/access_log \
		--error-log-path="${EPREFIX}"/var/log/${PN}/error_log \
		--pid-path="${EPREFIX}"/var/run/${PN}.pid \
		--http-client-body-temp-path="${EPREFIX}"/var/tmp/${PN}/client \
		--http-proxy-temp-path="${EPREFIX}"/var/tmp/${PN}/proxy \
		--http-fastcgi-temp-path="${EPREFIX}"/var/tmp/${PN}/fastcgi \
		${myconf} || die "configure failed"

	emake LINK="${CC} ${LDFLAGS}" OTHERLDFLAGS="${LDFLAGS}" || die "failed to compile"
}

src_install() {
	keepdir /var/log/${PN} /var/tmp/${PN}/{client,proxy,fastcgi}

	dosbin objs/nginx
	newinitd "${FILESDIR}"/nginx.init-r2 nginx || die

	cp "${FILESDIR}"/nginx.conf-r4 conf/nginx.conf

	dodir /etc/${PN}
	insinto /etc/${PN}
	doins conf/*

	dodoc CHANGES{,.ru} README

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/nginx.logrotate nginx || die

	use perl && {
		cd "${S}"/objs/src/http/modules/perl/
		einstall DESTDIR="${D}" INSTALLDIRS=vendor || die "failed to install perl stuff"
		fixlocalpod
	}
}

pkg_postinst() {
	use ssl && {
		if [ ! -f "${EROOT}"/etc/ssl/${PN}/${PN}.key ]; then
			install_cert /etc/ssl/${PN}/${PN}
			chown ${PN}:${PN} "${EROOT}"/etc/ssl/${PN}/${PN}.{crt,csr,key,pem}
		fi
	}
}
