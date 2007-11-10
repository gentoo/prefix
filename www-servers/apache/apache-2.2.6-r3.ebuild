# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/apache/apache-2.2.6-r3.ebuild,v 1.1 2007/10/25 02:07:54 hollow Exp $

EAPI="prefix"

inherit eutils flag-o-matic multilib autotools

# latest gentoo apache files
GENTOO_PATCHNAME="gentoo-${PF}"
GENTOO_PATCHSTAMP="20071025"
GENTOO_DEVSPACE="hollow"
GENTOO_PATCHDIR="${WORKDIR}/${GENTOO_PATCHNAME}"

DESCRIPTION="The Apache Web Server."
HOMEPAGE="http://httpd.apache.org/"
SRC_URI="mirror://apache/httpd/httpd-${PV}.tar.bz2
		http://dev.gentoo.org/~${GENTOO_DEVSPACE}/dist/apache/${GENTOO_PATCHNAME}-${GENTOO_PATCHSTAMP}.tar.bz2"

# some helper scripts are apache-1.1, thus both are here
LICENSE="Apache-2.0 Apache-1.1"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-fbsd"
IUSE="debug doc ldap mpm-event mpm-itk mpm-peruser mpm-prefork mpm-worker no-suexec selinux ssl static-modules threads"

DEPEND="dev-lang/perl
	=dev-libs/apr-1*
	=dev-libs/apr-util-1*
	dev-libs/expat
	dev-libs/libpcre
	sys-libs/zlib
	ldap? ( =net-nds/openldap-2* )
	selinux? ( sec-policy/selinux-apache )
	ssl? ( dev-libs/openssl )
	!=www-servers/apache-1*
	!=app-admin/apache-tools-2.2.4-r2"

RDEPEND="${DEPEND}
	app-misc/mime-types"

PDEPEND="~app-admin/apache-tools-${PV}"

S="${WORKDIR}/httpd-${PV}"

pkg_setup() {
	if use ldap && ! built_with_use 'dev-libs/apr-util' ldap ; then
		eerror "dev-libs/apr-util is missing LDAP support. For apache to have"
		eerror "ldap support, apr-util must be built with the ldap USE-flag"
		eerror "enabled."
		die "ldap USE-flag enabled while not supported in apr-util"
	fi

	# Select the default MPM module
	MPM_LIST="event itk peruser prefork worker"
	for x in ${MPM_LIST} ; do
		if use mpm-${x} ; then
			if [[ "x${mpm}" == "x" ]] ; then
				mpm=${x}
				elog
				elog "Selected MPM: ${mpm}"
				elog
			else
				eerror "You have selected more then one mpm USE-flag."
				eerror "Only one MPM is supported."
				die "more then one mpm was specified"
			fi
		fi
	done

	if [[ "x${mpm}" == "x" ]] ; then
		if use threads ; then
			mpm=worker
			elog
			elog "Selected default threaded MPM: ${mpm}";
			elog
		else
			mpm=prefork
			elog
			elog "Selected default MPM: ${mpm}";
			elog
		fi
	fi

	# setup apache user and group
	enewgroup apache 81
	enewuser apache 81 -1 /var/www apache

	if ! use no-suexec ; then
		elog
		elog "You can manipulate several configure options of suexec"
		elog "through the following environment variables:"
		elog
		elog " SUEXEC_SAFEPATH: Default PATH for suexec (default: ${EPREFIX}/usr/bin:${EPREFIX}/bin)"
		elog "  SUEXEC_LOGFILE: Path to the suexec logfile (default: ${EPREFIX}/var/log/apache2/suexec_log)"
		elog "   SUEXEC_CALLER: Name of the user Apache is running as (default: apache)"
		elog "  SUEXEC_DOCROOT: Directory in which suexec will run scripts (default: /var/www)"
		elog "   SUEXEC_MINUID: Minimum UID, which is allowed to run scripts via suexec (default: 1000)"
		elog "   SUEXEC_MINGID: Minimum GID, which is allowed to run scripts via suexec (default: 100)"
		elog "  SUEXEC_USERDIR: User subdirectories (like /home/user/html) (default: public_html)"
		elog "    SUEXEC_UMASK: Umask for the suexec process (default: 077)"
		elog
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Sloppily prefixify
	if use prefix ; then
		local files=$(find "${GENTOO_PATCHDIR}" -type f)
		for f in ${files} ; do
			ebegin "adjusting ${f##*/} to prefix"
			sed -i -e "s:\(/var\|/usr\|/etc\|/sbin\):${EPREFIX}\1:" "${f}"
			eend $?
		done
	fi

	# 03_all_gentoo-apache-tools.patch injects -Wl,-z,now, which is not a good
	# idea for everyone
	case ${CHOST} in
		*-linux-gnu|*-solaris*|*-freebsd*)
			# do nothing, these use GNU binutils
			:
		;;
		*-darwin*)
			sed -i -e 's/-Wl,-z,now/-Wl,-bind_at_load/g' \
				"${GENTOO_PATCHDIR}"/patches/03_all_gentoo-apache-tools.patch
		;;
		*)
			# patch it out to be like upstream
			sed -i -e 's/-Wl,-z,now//g' \
				"${GENTOO_PATCHDIR}"/patches/03_all_gentoo-apache-tools.patch
		;;
	esac

	# Use correct multilib libdir in gentoo patches
	sed -i -e "s:/usr/lib:/usr/$(get_libdir):g" \
		"${GENTOO_PATCHDIR}"/{conf/httpd.conf,init/*,patches/config.layout} \
		|| die "libdir sed failed"

	#### Patch Organization
	# 00-19 Gentoo specific  (00_all_some-title.patch)
	# 20-39 Additional MPMs  (20_all_${MPM}_some-title.patch)
	# 40-59 USE-flag based   (40_all_${USE}_some-title.patch)
	# 60-79 Version specific (60_all_${PV}_some-title.patch)
	# 80-99 Security patches (80_all_${PV}_cve-####-####.patch)

	epatch "${GENTOO_PATCHDIR}"/patches/*.patch

	# setup the filesystem layout config
	cat "${GENTOO_PATCHDIR}"/patches/config.layout >> "${S}"/config.layout || \
		die "Failed preparing config.layout!"
	sed -i -e "s:version:${PF}:g" "${S}"/config.layout

	# patched-in MPMs need the build environment rebuilt
	sed -i -e '/sinclude/d' configure.in
	AT_GNUCONF_UPDATE=yes AT_M4DIR=build eautoreconf

	# apache2.8 instead of httpd.8 (bug #194828)
	mv docs/man/{httpd,apache2}.8
}

src_compile() {
	local modtype="shared" myconf=""
	cd "${S}"

	# Instead of filtering --as-needed (bug #128505), append --no-as-needed
	# Thanks to Harald van Dijk
	case ${CHOST} in
		*-linux-gnu|*-solaris*|*-freebsd*)
			append-ldflags -Wl,--no-as-needed
		;;
	esac

	# peruser MPM debugging with -X is nearly impossible
	use mpm-peruser && use debug && append-flags -DMPM_PERUSER_DEBUG

	use static-modules && modtype="static"
	select_modules_config || die "determining modules failed"

	if use ldap ; then
		mods="${mods} ldap authnz_ldap"
		myconf="${myconf} --enable-authnz-ldap=${modtype} --enable-ldap=${modtype}"
	fi

	if use threads || use mpm-worker || use mpm-event; then
		mods="${mods} cgid"
		myconf="${myconf} --enable-cgid=${modtype}"
	else
		mods="${mods} cgi"
		myconf="${myconf} --enable-cgi=${modtype}"
	fi

	if use ssl; then
		mods="${mods} ssl"
		myconf="${myconf} --with-ssl=${EPREFIX}/usr --enable-ssl=${modtype}"
	fi

	if use debug; then
		myconf="${myconf} --enable-maintainer-mode --enable-exception-hook"
	fi

	# Only build suexec with USE=-no-suexec
	if use no-suexec ; then
		myconf="${myconf} --disable-suexec"
	else
		myconf="${myconf} --with-suexec-safepath=${SUEXEC_SAFEPATH:-${EPREFIX}/usr/bin:${EPREFIX}/bin}"
		myconf="${myconf} --with-suexec-logfile=${SUEXEC_LOGFILE:-${EPREFIX}/var/log/apache2/suexec_log}"
		myconf="${myconf} --with-suexec-bin=${EPREFIX}/usr/sbin/suexec"
		myconf="${myconf} --with-suexec-userdir=${SUEXEC_USERDIR:-public_html}"
		myconf="${myconf} --with-suexec-caller=${SUEXEC_CALLER:-apache}"
		myconf="${myconf} --with-suexec-docroot=${SUEXEC_DOCROOT:-${EPREFIX}/var/www}"
		myconf="${myconf} --with-suexec-uidmin=${SUEXEC_MINUID:-1000}"
		myconf="${myconf} --with-suexec-gidmin=${SUEXEC_MINGID:-100}"
		myconf="${myconf} --with-suexec-umask=${SUEXEC_UMASK:-077}"
		myconf="${myconf} --enable-suexec=${modtype}"
		mods="${mods} suexec"
	fi

	# econf overwrites the stuff from config.layout, so we have to put them into
	# our myconf line too

	econf \
		--includedir="${EPREFIX}"/usr/include/apache2 \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/apache2/modules \
		--datadir="${EPREFIX}"/var/www/localhost \
		--sysconfdir="${EPREFIX}"/etc/apache2 \
		--localstatedir="${EPREFIX}"/var \
		--with-mpm=${mpm} \
		--with-perl="${EPREFIX}"/usr/bin/perl \
		--with-expat="${EPREFIX}"/usr \
		--with-z="${EPREFIX}"/usr \
		--with-apr="${EPREFIX}"/usr \
		--with-apr-util="${EPREFIX}"/usr \
		--with-pcre="${EPREFIX}"/usr \
		--with-port=8000 \
		--with-program-name=apache2 \
		--enable-layout=Gentoo \
		${myconf} ${MY_BUILTINS} || die "econf failed!"

	sed -i -e 's:apache2\.conf:httpd.conf:' include/ap_config_auto.h

	emake || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"

	# This is a mapping of module names to the -D options in APACHE2_OPTS
	# Used for creating optional LoadModule lines
	mod_defines="
		auth_digest:AUTH_DIGEST
		authnz_ldap:AUTHNZ_LDAP
		cache:CACHE
		dav:DAV
		dav_fs:DAV
		dav_lock:DAV
		disk_cache:CACHE
		file_cache:CACHE
		info:INFO
		ldap:LDAP
		mem_cache:CACHE
		proxy:PROXY
		proxy_ajp:PROXY
		proxy_balancer:PROXY
		proxy_connect:PROXY
		proxy_http:PROXY
		ssl:SSL
		status:INFO
		suexec:SUEXEC
		userdir:USERDIR
	"

	# create our LoadModule lines
	if ! use static-modules ; then
		load_module=""
		moddir="${ED}/usr/$(get_libdir)/apache2/modules"
		for m in $(echo ${mods}|tr ' ' '\n'|sort -u) ; do
			endid="no"

			if [[ -e "${moddir}/mod_${m}.so" ]] ; then
				for def in ${mod_defines} ; do
					if [[ "${m}" == "${def%:*}" ]] ; then
						load_module="${load_module}\n<IfDefine ${def#*:}>"
						endid="yes"
					fi
				done
				load_module="${load_module}\nLoadModule ${m}_module modules/mod_${m}.so"
				if [[ "${endid}" == "yes" ]] ; then
					load_module="${load_module}\n</IfDefine>"
				fi
			fi
		done
	fi
	sed -i -e "s:%%LOAD_MODULE%%:${load_module}:" \
		"${GENTOO_PATCHDIR}"/conf/httpd.conf || die "sed failed"

	# Install our configuration files
	insinto /etc/apache2
	doins docs/conf/magic
	doins -r "${GENTOO_PATCHDIR}"/conf/*
	insinto /etc/logrotate.d
	newins "${GENTOO_PATCHDIR}"/scripts/apache2-logrotate apache2

	# generate a sane default APACHE2_OPTS
	APACHE2_OPTS="-D DEFAULT_VHOST -D INFO -D LANGUAGE"
	use doc && APACHE2_OPTS="${APACHE2_OPTS} -D MANUAL"
	use ssl && APACHE2_OPTS="${APACHE2_OPTS} -D SSL -D SSL_DEFAULT_VHOST"
	use no-suexec || APACHE2_OPTS="${APACHE2_OPTS} -D SUEXEC"

	sed -i -e "s:APACHE2_OPTS=\".*\":APACHE2_OPTS=\"${APACHE2_OPTS}\":" \
		"${GENTOO_PATCHDIR}"/init/apache2.confd || die "sed failed"

	newconfd "${GENTOO_PATCHDIR}"/init/apache2.confd apache2
	newinitd "${GENTOO_PATCHDIR}"/init/apache2.initd apache2

	# Link apache2ctl to the init script
	dosym /etc/init.d/apache2 /usr/sbin/apache2ctl

	# provide symlinks for all the stuff we no longer rename, bug 177697
	for i in suexec apxs; do
		dosym /usr/sbin/${i} /usr/sbin/${i}2
	done

	# Install some thirdparty scripts
	exeinto /usr/sbin
	use ssl && doexe "${GENTOO_PATCHDIR}"/scripts/gentestcrt.sh

	# Install some documentation
	dodoc ABOUT_APACHE CHANGES LAYOUT README README.platforms VERSIONING
	dodoc "${GENTOO_PATCHDIR}"/docs/*

	# drop in a convenient link to the manual
	if use doc ; then
		sed -i -e "s:VERSION:${PVR}:" "${ED}/etc/apache2/modules.d/00_apache_manual.conf"
	else
		rm -f "${ED}/etc/apache2/modules.d/00_apache_manual.conf"
		rm -Rf "${ED}/usr/share/doc/${PF}/manual"
	fi

	# the default webroot gets stored in /usr/share/doc
	ebegin "Installing default webroot to /usr/share/doc/${PF}"
	mv -f "${ED}/var/www/localhost" "${ED}/usr/share/doc/${PF}/webroot"
	eend $?
	keepdir /var/www/localhost/htdocs

	if ! use no-suexec ; then
		# Set some sane permissions for suexec
		fowners 0:apache /usr/sbin/suexec
		fperms 4710 /usr/sbin/suexec
	fi

	keepdir /etc/apache2/vhosts.d
	keepdir /etc/apache2/modules.d

	# empty dirs
	for i in /var/lib/dav /var/log/apache2 /var/cache/apache2 ; do
		keepdir ${i}
		fowners apache:apache ${i}
		fperms 0755 ${i}
	done

	# We'll be needing /etc/apache2/ssl if USE=ssl
	use ssl && keepdir /etc/apache2/ssl
}

pkg_postinst() {
	# Automatically generate test certificates if ssl USE flag is being set
	if use ssl && [[ ! -e "${EROOT}/etc/apache2/ssl/server.crt" ]] ; then
		cd "${EROOT}"/etc/apache2/ssl
		einfo
		einfo "Generating self-signed test certificate in ${EROOT}etc/apache2/ssl ..."
		yes "" 2>/dev/null | \
			"${EROOT}"/usr/sbin/gentestcrt.sh >/dev/null 2>&1 || \
			die "gentestcrt.sh failed"
		einfo
	fi

	# we do this here because the default webroot is a copy of the files
	# that exist elsewhere and we don't want them managed/removed by portage
	# when apache is upgraded.

	if [[ -e "${EROOT}/var/www/localhost" ]] ; then
		elog "The default webroot has not been installed into"
		elog "${EROOT}var/www/localhost because the directory already exists"
		elog "and we do not want to overwrite any files you have put there."
		elog
		elog "If you would like to install the latest webroot, please run"
		elog "emerge --config =${PF}"
	else
		einfo "Installing default webroot to ${EROOT}var/www/localhost"
		mkdir -p "${EROOT}"/var/www/localhost
		cp -R "${EROOT}"/usr/share/doc/${PF}/webroot/* "${EROOT}"/var/www/localhost
		chown -R apache:0 "${EROOT}"/var/www/localhost
	fi

	# Previous installations of apache-2.2 installed the upstream configuration
	# files, which shouldn't even have been installed!
	if has_version '>=www-servers/apache-2.2.4' ; then
		[ -f "${EROOT}"/etc/apache2/apache2.conf ] && \
			rm -f "${EROOT}"/etc/apache2/apache2.conf >/dev/null 2>&1

		for i in extra original ; do
			[ -d "${EROOT}"/etc/apache2/$i ] && \
				rm -rf "${EROOT}"/etc/apache2/$i >/dev/null 2>&1
		done
	fi

	# Note regarding IfDefine changes
	if has_version '<www-servers/apache-2.2.6-r1' ; then
		elog
		elog "When upgrading from versions 2.2.6 or earlier, please be aware"
		elog "that the define for mod_authnz_ldap has changed from AUTH_LDAP"
		elog "to AUTHNZ_LDAP. Additionally mod_auth_digest needs to be enabled"
		elog "with AUTH_DIGEST now."
		elog
	fi

	# Note the changes regarding DEFAULT_VHOST and SSL_DEFAULT_VHOST
	if has_version '<www-servers/apache-2.2.4-r7' ; then
		elog
		elog "Listen directives have been moved into the default virtual host"
		elog "configuation. At least DEFAULT_VHOST has been enabled for you"
		elog "(depending on your USE-flags."
		elog
		elog "If you disable DEFAULT_VHOST or SSL_DEFAULT_VHOST, there would"
		elog "be no listening sockets available."
		elog
	fi

	# Note the user of the config changes
	if has_version '<www-servers/apache-2.2.4-r5' ; then
		elog
		elog "Please make sure that you update your /etc directory."
		elog "Between the versions, we had to changes some config files"
		elog "and move some stuff out of the main httpd.conf file to a seperate"
		elog "modules.d entry."
		elog
		elog "Thus please update your /etc directory either via etc-update,"
		elog "dispatch-conf or conf-update !"
		elog
	fi

	# Check for dual/upgrade install
	if has_version '<www-servers/apache-2.2.0' ; then
		elog
		elog "When upgrading from versions below 2.2.0 to this version, you"
		elog "need to rebuild all your modules. Please do so for your modules"
		elog "to continue working correctly."
		elog
		elog "Also note that some configuration directives have been"
		elog "split into their own files under ${EROOT}etc/apache2/modules.d/"
		elog "and that some modules, foremost the authentication related ones,"
		elog "have been renamed."
		elog
		elog "Some examples:"
		elog "  - USERDIR is now configureable in ${EROOT}etc/apache2/modules.d/00_mod_userdir.conf."
		elog
		elog "For more information on what you may need to change, please"
		elog "see the overview of changes at:"
		elog "http://httpd.apache.org/docs/2.2/new_features_2_2.html"
		elog "and the upgrading guide at:"
		elog "http://httpd.apache.org/docs/2.2/upgrading.html"
		elog
	fi

	# Cleanup the vim backup files, placed in /etc/apache2 by the last
	# patchtarball (gentoo-apache-2.2.4-r7-20070615)
	rm -f "${EROOT}/etc/apache2/modules.d/*.conf~"
}

pkg_config() {
	einfo "Installing default webroot to ${EROOT}var/www/localhost"
	mkdir "${EROOT}"var{,/www{,/localhost}}
	cp -R "${EROOT}"usr/share/doc/${PF}/webroot/* "${EROOT}"var/www/localhost/
}

parse_modules_config() {
	local name=""
	local disable=""
	local version="undef"
	MY_BUILTINS=""
	mods=""
	[[ -f "${1}" ]] || return 1

	for i in $(sed 's/#.*//' < $1) ; do
		if [[ "$i" == "VERSION:" ]] ; then
			version="select"
		elif [[ "${version}" == "select" ]] ; then
			version="$i"
		# start with - option for backwards compatibility only
		elif [[ "$i" == "-" ]] ; then
			disable="true"
		elif [[ -z "${name}" ]] && [[ "$i" != "${i/mod_/}" ]] ; then
			name="${i/mod_/}"
		elif [[ -n "${disable}" ]] || [[ "$i" == "disabled" ]] ; then
			MY_BUILTINS="${MY_BUILTINS} --disable-${name}"
			name="" ; disable=""
		elif [[ "$i" == "static" ]] || use static-modules ; then
			MY_BUILTINS="${MY_BUILTINS} --enable-${name}=static"
			name="" ; disable=""
		elif [[ "$i" == "shared" ]] ; then
			MY_BUILTINS="${MY_BUILTINS} --enable-${name}=shared"
			mods="${mods} ${name}"
			name="" ; disable=""
		else
			ewarn "Parse error in ${1} - unknown option: $i"
		fi
	done

	# reject the file if it's unversioned or doesn't match our
	# package major.minor. This is to make upgrading work smoothly.
	if [[ "${version}" != "${PV%.*}" ]] ; then
		mods=""
		MY_BUILTINS=""
		return 1
	fi

	einfo "Using ${1}"
	einfo "options: ${MY_BUILTINS}"
	einfo "LoadModules: ${mods}"
}

select_modules_config() {
	parse_modules_config "${EROOT}"/etc/apache2/apache2-builtin-mods || \
	parse_modules_config "${GENTOO_PATCHDIR}"/conf/apache2-builtin-mods || \
	return 1
}
