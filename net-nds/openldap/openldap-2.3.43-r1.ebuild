# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-nds/openldap/openldap-2.3.43-r1.ebuild,v 1.8 2010/04/11 15:24:10 jokey Exp $

EAPI=2

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
AT_M4DIR="./build"
inherit autotools db-use eutils flag-o-matic multilib ssl-cert toolchain-funcs versionator

DESCRIPTION="LDAP suite of application and development tools"
HOMEPAGE="http://www.OpenLDAP.org/"
SRC_URI="mirror://openldap/openldap-release/${P}.tgz"

LICENSE="OPENLDAP"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris ~x86-winnt"
IUSE="berkdb crypt debug gdbm ipv6 kerberos minimal odbc overlays perl samba sasl slp smbkrb5passwd ssl tcpd selinux"

# note that the 'samba' USE flag pulling in OpenSSL is NOT an error.  OpenLDAP
# uses OpenSSL for LanMan/NTLM hashing (which is used in some enviroments, like
# mine at work)!
# Robin H. Johnson <robbat2@gentoo.org> March 8, 2004

# note: the ncurses dependency is really optional, but cannot be controlled by
# configure, it seems. so i disable the dependency only on winnt, where there
# is no ncurses, instead of making a USE flags for it..

RDEPEND="!x86-winnt? ( sys-libs/ncurses )
	tcpd? ( sys-apps/tcp-wrappers )
	ssl? ( dev-libs/openssl )
	sasl? ( dev-libs/cyrus-sasl )
	!minimal? (
		odbc? ( dev-db/unixODBC )
		slp? ( net-libs/openslp )
		perl? ( dev-lang/perl[-build] )
		samba? ( dev-libs/openssl )
		kerberos? ( virtual/krb5 )
		berkdb? (
			|| ( 	sys-libs/db:4.5
				sys-libs/db:4.4
				sys-libs/db:4.3
				>=sys-libs/db-4.2.52_p2-r1:4.2
			)
		)
		!berkdb? (
			gdbm? ( sys-libs/gdbm )
			!gdbm? (
				|| (	sys-libs/db:4.5
					sys-libs/db:4.4
					sys-libs/db:4.3
					>=sys-libs/db-4.2.52_p2-r1:4.2
				)
			)
		)
		smbkrb5passwd? (
			dev-libs/openssl
			app-crypt/heimdal
		)
	)
	selinux? ( sec-policy/selinux-openldap )"
DEPEND="${RDEPEND}"

# for tracking versions
OPENLDAP_VERSIONTAG=".version-tag"
OPENLDAP_DEFAULTDIR_VERSIONTAG="/var/lib/openldap-data"

openldap_upgrade_howto() {
	eerror
	eerror "A (possible old) installation of OpenLDAP was detected,"
	eerror "installation will not proceed for now."
	eerror
	eerror "As major version upgrades can corrupt your database,"
	eerror "you need to dump your database and re-create it afterwards."
	eerror ""
	d="$(date -u +%s)"
	l="/root/ldapdump.${d}"
	i="${l}.raw"
	eerror " 1. /etc/init.d/slurpd stop ; /etc/init.d/slapd stop"
	eerror " 2. slapcat -l ${i}"
	eerror " 3. egrep -v '^entryCSN:' <${i} >${l}"
	eerror " 4. mv /var/lib/openldap-data/ /var/lib/openldap-data-backup/"
	eerror " 5. emerge --update \=net-nds/${PF}"
	eerror " 6. etc-update, and ensure that you apply the changes"
	eerror " 7. slapadd -l ${l}"
	eerror " 8. chown ldap:ldap /var/lib/openldap-data/*"
	eerror " 9. /etc/init.d/slapd start"
	eerror "10. check that your data is intact."
	eerror "11. set up the new replication system."
	eerror
	die "You need to upgrade your database first"
}

openldap_find_versiontags() {
	# scan for all datadirs
	openldap_datadirs=""
	if [ -f "${EROOT}"/etc/openldap/slapd.conf ]; then
		openldap_datadirs="$(awk '{if($1 == "directory") print $2 }' ${EROOT}/etc/openldap/slapd.conf)"
	fi
	openldap_datadirs="${openldap_datadirs} ${OPENLDAP_DEFAULTDIR_VERSIONTAG}"

	einfo
	einfo "Scanning datadir(s) from slapd.conf and"
	einfo "the default installdir for Versiontags"
	einfo "(${OPENLDAP_DEFAULTDIR_VERSIONTAG} may appear twice)"
	einfo

	# scan datadirs if we have a version tag
	openldap_found_tag=0
	for each in ${openldap_datadirs}; do
		CURRENT_TAGDIR=${EROOT}`echo ${each} | sed "s:\/::"`
		CURRENT_TAG=${CURRENT_TAGDIR}/${OPENLDAP_VERSIONTAG}
		if [ -d ${CURRENT_TAGDIR} ] &&	[ ${openldap_found_tag} == 0 ] ; then
			einfo "- Checking ${each}..."
			if [ -r ${CURRENT_TAG} ] ; then
				# yey, we have one :)
				einfo "   Found Versiontag in ${each}"
				source ${CURRENT_TAG}
				if [ "${OLDPF}" == "" ] ; then
					eerror "Invalid Versiontag found in ${CURRENT_TAGDIR}"
					eerror "Please delete it"
					eerror
					die "Please kill the invalid versiontag in ${CURRENT_TAGDIR}"
				fi

				OLD_MAJOR=`get_version_component_range 2-3 ${OLDPF}`

				# are we on the same branch?
				if [ "${OLD_MAJOR}" != "${PV:0:3}" ] ; then
					ewarn "   Versiontag doesn't match current major release!"
					if [[ `ls -a ${CURRENT_TAGDIR} | wc -l` -gt 5 ]] ; then
						eerror "   Versiontag says other major and you (probably) have datafiles!"
						echo
						openldap_upgrade_howto
					else
						einfo "   No real problem, seems there's no database."
					fi
				else
					einfo "   Versiontag is fine here :)"
				fi
			else
				einfo "   Non-tagged dir ${each}"
				if [[ `ls -a ${each} | wc -l` > 5 ]] ; then
					einfo "   EEK! Non-empty non-tagged datadir, counting `ls -a ${each} | wc -l` files"
					echo

					eerror
					eerror "Your OpenLDAP Installation has a non tagged datadir that"
					eerror "possibly contains a database at ${CURRENT_TAGDIR}"
					eerror
					eerror "Please export data if any entered and empty or remove"
					eerror "the directory, installation has been stopped so you"
					eerror "can take required action"
					eerror
					eerror "For a HOWTO on exporting the data, see instructions in the ebuild"
					eerror
					die "Please move the datadir ${CURRENT_TAGDIR} away"
				fi
			fi
			einfo
		fi
	done

	echo
	einfo
	einfo "All datadirs are fine, proceeding with merge now..."
	einfo

}

pkg_setup() {
	if has_version "<=dev-lang/perl-5.8.8_rc1" && built_with_use dev-lang/perl minimal ; then
		die "You must have a complete (USE='-minimal') Perl install to use the perl backend!"
	fi

	if use samba && ! use ssl ; then
		eerror "LAN manager passwords need ssl flag set"
		die "Please set ssl useflag"
	fi

	if use minimal && has_version "net-nds/openldap" && built_with_use net-nds/openldap minimal ; then
		einfo
		einfo "Skipping scan for previous datadirs as requested by minimal useflag"
		einfo
	else
		openldap_find_versiontags
	fi

	use prefix || enewgroup ldap 439
	use prefix || enewuser ldap 439 -1 /usr/$(get_libdir)/openldap ldap
}

src_prepare() {
	# According to MDK, the link order needs to be changed so that
	# on systems w/ MD5 passwords the system crypt library is used
	# (the net result is that "passwd" can be used to change ldap passwords w/
	#  proper pam support)
	sed -i -e 's/$(SECURITY_LIBS) $(LDIF_LIBS) $(LUTIL_LIBS)/$(LUTIL_LIBS) $(SECURITY_LIBS) $(LDIF_LIBS)/' \
		"${S}"/servers/slapd/Makefile.in

	# supersedes old fix for bug #31202
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-2.2.14-perlthreadsfix.patch

	# ensure correct SLAPI path by default
	sed -i -e 's,\(#define LDAPI_SOCK\).*,\1 "/var/run/openldap/slapd.sock",' \
		"${S}"/include/ldap_defaults.h

	EPATCH_OPTS="-p0 -d ${S}"

	# ximian connector 1.4.7 ntlm patch
	epatch "${FILESDIR}"/${PN}-2.2.6-ntlm.patch

	# bug #132263
	epatch "${FILESDIR}"/${PN}-2.3.21-ppolicy.patch

	# bug #189817
	epatch "${FILESDIR}"/${PN}-2.3.37-libldap_r.patch

	# missing --tag for libtool
	epatch "${FILESDIR}"/${P}-tag-lt.patch

	# fix up stuff for newer autoconf that simulates autoconf-2.13, but doesn't
	# do it perfectly.
	cd "${S}"/build
	ln -s shtool install
	ln -s shtool install.sh
	einfo "Making sure upstream build strip does not do stripping too early"
	sed -i.orig \
		-e '/^STRIP/s,-s,,g' \
		top.mk || die "Failed to block stripping"

	# bug #116045
	# patch contrib modules
	if ! use minimal ; then
		cd "${S}"/contrib
		epatch "${FILESDIR}"/${PN}-2.3.24-contrib-smbk5pwd.patch
	fi

	# the following is conditional, since its everything but clean.
	# still this is the only solution that i could come up with after
	# a few hours of troubles with eautoreconf and friends...
	if [[ ${CHOST} == *-winnt* || ${CHOST} == *-aix* ]]; then
		unset EPATCH_OPTS
		cd "${S}"

		epatch "${FILESDIR}"/${P}-r1-winnt.patch

		for x in "${S}" "${S}/contrib/ldapc++"; do
			cd $x
			libtoolize --force --copy

			# don't use eaclocal, since this tries to include "build"
			# which doesn't work.
			aclocal
			eautoconf
			elibtoolize --force
		done
	fi
	# Fix gcc-4.4 compat, bug 264761
# doesn't apply
	#epatch "${FILESDIR}/openldap-2.3.XY-gcc44.patch"
}

src_configure() {
	local myconf

	#Fix for glibc-2.8 and ucred. Bug 228457.
	if [[ ${CHOST} != *-winnt* ]]; then
		append-flags -D_GNU_SOURCE
	else
		# big hack: parity automaticall tries to lookup and
		# export symbols as required. but when building openldap,
		# some test programs are linked against liblutil.a, which
		# contains unresolvable symbols, which are contained in
		# libraries, which aren't build (and aren't buildable ATM).
		# to make this work with parity, we need to tell it, to not
		# try to automatically DTRT when building executables.
		# in this special case this doesn't do any harm.
		local conf="${T}"/parity-no-exe-export.cfg
		echo "ExportFromExe=off" > "${conf}"
		export PARITY_CONFIG="${conf}"
	fi

	# shared modules don't work with parity build, since that
	# would require exporting from executables, which we have to
	# explicitly disable above to make building the basics possible.
	local enable_module
	if [[ ${CHOST} == *-winnt* ]]; then
		enable_module="yes"
		enable_module_nowin="no"
	else
		enable_module="mod"
		enable_module_nowin="mod"
	fi

	# HDB is only available with BerkDB
	myconf_berkdb="--enable-bdb --enable-ldbm-api=berkeley --enable-hdb=${enable_module_nowin}"
	myconf_gdbm='--disable-bdb --enable-ldbm-api=gdbm --disable-hdb'

	use debug && myconf="${myconf} --enable-debug" # there is no disable-debug

	# enable slapd/slurpd servers if not doing a minimal build
	if ! use minimal ; then
		myconf="${myconf} --enable-slapd --enable-slurpd"
		# base backend stuff
		myconf="${myconf} --enable-ldbm"
		if use berkdb ; then
			einfo "Using Berkeley DB for local backend"
			myconf="${myconf} ${myconf_berkdb}"
			# We need to include the slotted db.h dir for FreeBSD
			append-cppflags -I$(db_includedir 4.5 4.4 4.3 4.2 )
		elif use gdbm ; then
			einfo "Using GDBM for local backend"
			myconf="${myconf} ${myconf_gdbm}"
		else
			ewarn "Neither gdbm or berkdb USE flags present, falling back to"
			ewarn "Berkeley DB for local backend"
			myconf="${myconf} ${myconf_berkdb}"
			# We need to include the slotted db.h dir for FreeBSD
			append-cppflags -I$(db_includedir 4.5 4.4 4.3 4.2 )
		fi
		# extra backend stuff
		myconf="${myconf} --enable-passwd=${enable_module_nowin} --enable-phonetic=${enable_module}"
		myconf="${myconf} --enable-dnssrv=${enable_module_nowin} --enable-ldap"
		myconf="${myconf} --enable-meta=${enable_module} --enable-monitor=${enable_module}"
		myconf="${myconf} --enable-null=${enable_module} --enable-shell=${enable_module_nowin}"
		myconf="${myconf} --enable-relay=${enable_module}"
		myconf="${myconf} $(use_enable perl perl ${enable_module})"
		myconf="${myconf} $(use_enable odbc sql ${enable_module})"
		# slapd options
		myconf="${myconf} $(use_enable crypt) $(use_enable slp)"
		myconf="${myconf} --enable-rewrite --enable-rlookups"
		myconf="${myconf} --enable-aci --enable-${enable_module}"

		[[ ${CHOST} != *-winnt* ]] && \
			myconf="${myconf} --enable-slapi"

		myconf="${myconf} --enable-cleartext"
		myconf="${myconf} $(use_enable samba lmpasswd)"
		# slapd overlay options
		myconf="${myconf} --enable-dyngroup --enable-proxycache"
		use overlays && myconf="${myconf} --enable-overlays=${enable_module}"
		myconf="${myconf} --enable-syncprov"
	else
		myconf="${myconf} --disable-slapd --disable-slurpd"
		myconf="${myconf} --disable-bdb --disable-ldbm"
		myconf="${myconf} --disable-hdb --disable-monitor"
		myconf="${myconf} --disable-slurpd --disable-overlays"
		myconf="${myconf} --disable-relay"
	fi

	# basic functionality stuff
	myconf="${myconf} --enable-dynamic --enable-proctitle"

	[[ ${CHOST} != *-winnt* ]] && \
		myconf="${myconf} --enable-local --enable-syslog"

	myconf="${myconf} $(use_enable ipv6)"
	myconf="${myconf} $(use_with sasl cyrus-sasl) $(use_enable sasl spasswd)"
	myconf="${myconf} $(use_enable tcpd wrappers) $(use_with ssl tls)"

	if [ $(get_libdir) != "lib" ] ; then
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)
	fi

	STRIP=/bin/true \
	tc-export CC CXX
	econf \
		--enable-static \
		--enable-shared \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/openldap \
		${myconf} || die "configure failed"
}

src_compile() {
	emake depend || die "make depend failed"
	emake || die "make failed"

	# openldap/contrib (not supported on winnt)
	if ! use minimal && [[ ${CHOST} != *-winnt* ]] ; then
		# dsaschema
			einfo "Building contributed dsaschema"
			cd "${S}"/contrib/slapd-modules/dsaschema
			${CC} -shared -I../../../include ${CFLAGS} -fPIC \
			-Wall -o libdsaschema-plugin.so dsaschema.c \
			-L"${S}"/libraries/libldap/.libs -lldap || \
			die "failed to compile dsaschema module"
		# kerberos passwd
		if use kerberos ; then
			einfo "Building contributed pw-kerberos"
			cd "${S}"/contrib/slapd-modules/passwd/ && \
			${CC} -shared -I../../../include ${CFLAGS} -fPIC \
			$(krb5-config --cflags) \
			-DHAVE_KRB5 -o pw-kerberos.so kerberos.c || \
			die "failed to compile kerberos password module"
		fi
		# netscape mta-md5 password
			einfo "Building contributed pw-netscape"
			cd "${S}"/contrib/slapd-modules/passwd/ && \
			${CC} -shared -I../../../include ${CFLAGS} -fPIC \
			-o pw-netscape.so netscape.c || \
			die "failed to compile netscape password module"
		# smbk5pwd overlay
		# Note: this modules builds, but may not work with
		#	Gentoo's MIT-Kerberos.	It was designed for Heimdal
		#	Kerberos.
		if use smbkrb5passwd ; then
			einfo "Building contributed smbk5pwd"
			local mydef
			local mykrb5inc
			mydef="-DDO_SAMBA -DDO_KRB5"
			mykrb5inc="$(krb5-config --cflags)"
			cd "${S}"/contrib/slapd-modules/smbk5pwd && \
			libexecdir="${EPREFIX}/usr/$(get_libdir)/openldap" \
			DEFS="${mydef}" KRB5_INC="${mykrb5inc}" emake || \
			die "failed to compile smbk5pwd module"
		fi
		# addrdnvalues
			einfo "Building contributed addrdnvalues"
			cd "${S}"/contrib/slapi-plugins/addrdnvalues/ && \
			${CC} -shared -I../../../include ${CFLAGS} -fPIC \
			-o libaddrdnvalues-plugin.so addrdnvalues.c || \
			die "failed to compile addrdnvalues plugin"
	fi
}

src_test() {
	einfo "Doing tests"
	cd tests ; make tests || die "make tests failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ANNOUNCEMENT CHANGES COPYRIGHT README "${FILESDIR}"/DB_CONFIG.fast.example
	docinto rfc ; dodoc doc/rfc/*.txt

	# openldap modules go here
	# TODO: write some code to populate slapd.conf with moduleload statements
	keepdir /usr/$(get_libdir)/openldap/openldap/

	# make state directories
	local dirlist="data"
	if ! use minimal; then
		dirlist="${dirlist} slurp ldbm"
	fi
	for x in ${dirlist}; do
		keepdir /var/lib/openldap-${x}
		use prefix || fowners ldap:ldap /var/lib/openldap-${x}
		fperms 0700 /var/lib/openldap-${x}
	done

	echo "OLDPF='${PF}'" > "${ED}${OPENLDAP_DEFAULTDIR_VERSIONTAG}/${OPENLDAP_VERSIONTAG}"
	echo "# do NOT delete this. it is used"	>> "${ED}${OPENLDAP_DEFAULTDIR_VERSIONTAG}/${OPENLDAP_VERSIONTAG}"
	echo "# to track versions for upgrading." >> "${ED}${OPENLDAP_DEFAULTDIR_VERSIONTAG}/${OPENLDAP_VERSIONTAG}"

	# manually remove /var/tmp references in .la
	# because it is packaged with an ancient libtool
	#for x in "${ED}"/usr/$(get_libdir)/lib*.la; do
	#	sed -i -e "s:-L${S}[/]*libraries::" ${x}
	#done

	# change slapd.pid location in configuration file
	keepdir /var/run/openldap
	use prefix || fowners ldap:ldap /var/run/openldap
	fperms 0755 /var/run/openldap

	if ! use minimal; then
		# use our config
		rm "${ED}"etc/openldap/slapd.con*
		insinto /etc/openldap
		newins "${FILESDIR}"/${PN}-2.3.34-slapd-conf slapd.conf
		configfile="${ED}"etc/openldap/slapd.conf

		# populate with built backends
		# nothing to be done here on winnt
		if [[ ${CHOST} != *-winnt* ]]; then
			ebegin "populate config with built backends"
			for x in "${ED}"usr/$(get_libdir)/openldap/openldap/back_*.so; do
				elog "Adding $(basename ${x})"
				sed -e "/###INSERTDYNAMICMODULESHERE###$/a# moduleload\t$(basename ${x})" -i "${configfile}"
			done
			sed -e "s:###INSERTDYNAMICMODULESHERE###$:# modulepath\t${EPREFIX}/usr/$(get_libdir)/openldap/openldap:" -i "${configfile}"
			use prefix || fowners root:ldap /etc/openldap/slapd.conf
			fperms 0640 /etc/openldap/slapd.conf
			cp "${configfile}" "${configfile}".default
			eend
		fi

		# install our own init scripts
		newinitd "${FILESDIR}"/slapd-initd slapd
		newinitd "${FILESDIR}"/slurpd-initd slurpd
		newconfd "${FILESDIR}"/slapd-confd slapd

		if [ $(get_libdir) != lib ]; then
			sed -e "s,/usr/lib/,/usr/$(get_libdir)/," -i "${ED}"etc/init.d/{slapd,slurpd}
		fi

		# install contributed modules
		docinto /
		if [ -e "${S}"/contrib/slapd-modules/dsaschema/libdsaschema-plugin.so ];
		then
			cd "${S}"/contrib/slapd-modules/dsaschema/
			newdoc README README.contrib.dsaschema
			exeinto /usr/$(get_libdir)/openldap/openldap
			doexe libdsaschema-plugin.so || \
			die "failed to install dsaschema module"
		fi
		if [ -e "${S}"/contrib/slapd-modules/passwd/pw-kerberos.so ]; then
			cd "${S}"/contrib/slapd-modules/passwd/
			newdoc README README.contrib.passwd
			exeinto /usr/$(get_libdir)/openldap/openldap
			doexe pw-kerberos.so || \
			die "failed to install kerberos passwd module"
		fi
		if [ -e "${S}"/contrib/slapd-modules/passwd/pw-netscape.so ]; then
			cd "${S}"/contrib/slapd-modules/passwd/
			newdoc README README.contrib.passwd
			exeinto /usr/$(get_libdir)/openldap/openldap
			doexe "${S}"/contrib/slapd-modules/passwd/pw-netscape.so || \
			die "failed to install Netscape MTA-MD5 passwd module"
		fi
		if [ -e "${S}"/contrib/slapd-modules/smbk5pwd/.libs/smbk5pwd.so ]; then
			cd "${S}"/contrib/slapd-modules/smbk5pwd
			newdoc README README.contrib.smbk5pwd
			libexecdir="/usr/$(get_libdir)/openldap" \
			emake DESTDIR="${D}" install-mod || \
			die "failed to install smbk5pwd overlay module"
		fi
		if [ -e "${S}"/contrib/slapd-tools/statslog ]; then
			cd "${S}"/contrib/slapd-tools
			exeinto /usr/bin
			newexe statslog ldapstatslog || \
			die "failed to install ldapstatslog script"
		fi
		if [ -e "${S}"/contrib/slapi-plugins/addrdnvalues/libaddrdnvalues-plugin.so ];
		then
			cd "${S}"/contrib/slapi-plugins/addrdnvalues
			newdoc README README.contrib.addrdnvalues
			exeinto /usr/$(get_libdir)/openldap/openldap
			doexe libaddrdnvalues-plugin.so || \
			die "failed to install addrdnvalues plugin"
		fi
	fi
}

pkg_preinst() {
	# keep old libs if any
	LIBSUFFIXES=".so.2.0.130 -2.2.so.7"
	for LIBSUFFIX in ${LIBSUFFIXES} ; do
		for each in libldap libldap_r liblber ; do
			preserve_old_lib "usr/$(get_libdir)/${each}${LIBSUFFIX}"
		done
	done
}

pkg_postinst() {
	if ! use minimal ; then
		# You cannot build SSL certificates during src_install that will make
		# binary packages containing your SSL key, which is both a security risk
		# and a misconfiguration if multiple machines use the same key and cert.
		# Additionally, it overwrites
		# for some strange reason this doesn't work on winnt. it works when
		# called directly from the command line. i don't have time to look this
		# up right now, so i'll leave it as is for now.
		if use ssl && [[ ${CHOST} != *-winnt* ]]; then
			install_cert /etc/openldap/ssl/ldap
			use prefix || chown ldap:ldap "${EROOT}"etc/openldap/ssl/ldap.*
			ewarn "Self-signed SSL certificates are treated harshly by OpenLDAP 2.[12]"
			ewarn "Self-signed SSL certificates are treated harshly by OpenLDAP 2.[12]"
			ewarn "add 'TLS_REQCERT never' if you want to use them."
		fi
		# These lines force the permissions of various content to be correct
		use prefix || chown ldap:ldap "${EROOT}"var/run/openldap
		chmod 0755 "${EROOT}"var/run/openldap
		use prefix || chown root:ldap "${EROOT}"etc/openldap/slapd.conf{,.default}
		chmod 0640 "${EROOT}"etc/openldap/slapd.conf{,.default}
		use prefix || chown ldap:ldap "${EROOT}"var/lib/openldap-{data,ldbm,slurp}
	fi

	# Reference inclusion bug #77330
	echo
	elog
	elog "Getting started using OpenLDAP? There is some documentation available:"
	elog "Gentoo Guide to OpenLDAP Authentication"
	elog "(http://www.gentoo.org/doc/en/ldap-howto.xml)"
	elog

	# note to bug #110412
	echo
	elog
	elog "An example file for tuning BDB backends with openldap is"
	elog "DB_CONFIG.fast.example in /usr/share/doc/${PF}/"
	elog

	LIBSUFFIXES=".so.2.0.130 -2.2.so.7"
	for LIBSUFFIX in ${LIBSUFFIXES} ; do
		for each in liblber libldap libldap_r ; do
			preserve_old_lib_notify "usr/$(get_libdir)/${each}${LIBSUFFIX}"
		done
	done
}
