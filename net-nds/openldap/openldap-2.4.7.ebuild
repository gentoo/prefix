# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-nds/openldap/openldap-2.4.7.ebuild,v 1.8 2009/03/07 13:04:12 gentoofan23 Exp $

EAPI=1
inherit db-use eutils flag-o-matic multilib ssl-cert versionator

DESCRIPTION="LDAP suite of application and development tools"
HOMEPAGE="http://www.OpenLDAP.org/"
SRC_URI="mirror://openldap/openldap-release/${P}.tgz"

LICENSE="OPENLDAP"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

IUSE_DAEMON="crypt samba slp tcpd experimental minimal"
IUSE_BACKEND="+berkdb"
IUSE_OVERLAY="overlays perl"
IUSE_OPTIONAL="sasl ssl odbc debug ipv6 syslog selinux"
IUSE="${IUSE_DAEMON} ${IUSE_BACKEND} ${IUSE_OVERLAY} ${IUSE_OPTIONAL}"

#Inspect:
#IUSE="selinux"

# samba adding openssl is intentional --jokey
RDEPEND="sys-libs/ncurses
	tcpd? ( sys-apps/tcp-wrappers )
	ssl? ( dev-libs/openssl )
	sasl? ( dev-libs/cyrus-sasl )
	!minimal? (
		odbc? ( dev-db/unixODBC )
		slp? ( net-libs/openslp )
		perl? ( dev-lang/perl )
		samba? ( dev-libs/openssl )
		berkdb? ( sys-libs/db:4.5 )
	)
	selinux? ( sec-policy/selinux-openldap )"
DEPEND="${RDEPEND}"

# for tracking versions
OPENLDAP_VERSIONTAG=".version-tag"
OPENLDAP_DEFAULTDIR_VERSIONTAG="/var/lib/openldap-data"

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

pkg_setup() {
	if use minimal && has_version "net-nds/openldap" && built_with_use net-nds/openldap minimal ; then
		einfo
		einfo "Skipping scan for previous datadirs as requested by minimal useflag"
		einfo
	else
		openldap_find_versiontags
	fi

	enewgroup ldap 439
	enewuser ldap 439 -1 /usr/$(get_libdir)/openldap ldap
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# ensure correct SLAPI path by default
	sed -i -e 's,\(#define LDAPI_SOCK\).*,\1 "'"${EPREFIX}"'/var/run/openldap/slapd.sock",' \
		"${S}"/include/ldap_defaults.h

	epatch "${FILESDIR}"/${PN}-2.2.14-perlthreadsfix.patch
	epatch "${FILESDIR}"/${PN}-2.4-disable-bdb46.patch
	epatch "${FILESDIR}"/${PN}-2.4-ppolicy.patch

	# bug #116045
	epatch "${FILESDIR}"/${PN}-2.3.24-contrib-smbk5pwd.patch

	cd "${S}"/build
	einfo "Making sure upstream build strip does not do stripping too early"
	sed -i.orig \
		-e '/^STRIP/s,-s,,g' \
		top.mk || die "Failed to block stripping"
}

src_compile() {
	local myconf

	#Fix for glibc-2.8 and ucred. Bug 228457.
	append-flags -D_GNU_SOURCE

	use debug && myconf="${myconf} $(use_enable debug)"

	if ! use minimal ; then
		# backends
		myconf="${myconf} --enable-slapd"
		if use berkdb ; then
			einfo "Using Berkeley DB for local backend"
			myconf="${myconf} --enable-bdb --enable-hdb"
			# We need to include the slotted db.h dir for FreeBSD
			append-cppflags -I$(db_includedir)
		else
			ewarn
			ewarn "Note: if you disable berkdb, you can only use remote-backends!"
			ewarn
			ebeep 5
			myconf="${myconf} --disable-bdb --disable-hdb"
		fi
		for backend in dnssrv ldap meta monitor null passwd relay shell; do
			myconf="${myconf} --enable-${backend}=mod"
		done
		myconf="${myconf} $(use_enable perl perl mod)"
		use odbc && myconf="${myconf} --enable-sql=mod --with-odbc=unixodbc"

		# slapd options
		myconf="${myconf} $(use_enable crypt) $(use_enable slp)"
		myconf="${myconf} $(use_enable samba lmpasswd)"
		if use experimental ; then
			myconf="${myconf} --enable-dynacl"
			myconf="${myconf} --enable-aci=mod"
		fi
		for option in aci cleartext modules rewrite rlookups slapi; do
			myconf="${myconf} --enable-${option}"
		done

		# slapd overlay options
		myconf="${myconf} --enable-syncprov"
		use overlays && myconf="${myconf} --enable-overlays=mod"
	else
		myconf="${myconf} --disable-slapd --disable-bdb --disable-hdb"
		myconf="${myconf} --disable-overlays"
	fi

	# basic functionality stuff
	myconf="${myconf} $(use_enable ipv6)"
	myconf="${myconf} $(use_with sasl cyrus-sasl) $(use_enable sasl spasswd)"
	myconf="${myconf} $(use_enable tcpd wrappers) $(use_with ssl tls openssl)"
	for basicflag in dynamic local proctitle shared static syslog; do
		myconf="${myconf} --enable-${basicflag}"
	done

	STRIP=/bin/true \
	econf \
		--libexecdir=/usr/$(get_libdir)/openldap \
		${myconf} || die "configure failed"

	emake depend || die "emake depend failed"
	emake || die "emake failed"
}

src_test() {
	cd tests ; make tests || die "make tests failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ANNOUNCEMENT CHANGES COPYRIGHT README "${FILESDIR}"/DB_CONFIG.fast.example
	docinto rfc ; dodoc doc/rfc/*.txt

	# openldap modules go here
	# TODO: write some code to populate slapd.conf with moduleload statements
	keepdir /usr/$(get_libdir)/openldap/openldap/

	# initial data storage dir
	keepdir /var/lib/openldap-data
	use prefix || fowners ldap:ldap /var/lib/openldap-data
	fperms 0700 /var/lib/openldap-data

	echo "OLDPF='${PF}'" > "${ED}${OPENLDAP_DEFAULTDIR_VERSIONTAG}/${OPENLDAP_VERSIONTAG}"
	echo "# do NOT delete this. it is used"	>> "${ED}${OPENLDAP_DEFAULTDIR_VERSIONTAG}/${OPENLDAP_VERSIONTAG}"
	echo "# to track versions for upgrading." >> "${ED}${OPENLDAP_DEFAULTDIR_VERSIONTAG}/${OPENLDAP_VERSIONTAG}"

	# change slapd.pid location in configuration file
	keepdir /var/run/openldap
	use prefix || fowners ldap:ldap /var/run/openldap
	fperms 0755 /var/run/openldap

	if ! use minimal; then
		# use our config
		rm "${ED}"etc/openldap/slapd.conf
		insinto /etc/openldap
		newins "${FILESDIR}"/${PN}-2.3.34-slapd-conf slapd.conf
		configfile="${ED}"etc/openldap/slapd.conf

		# populate with built backends
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

		# install our own init scripts
		newinitd "${FILESDIR}"/slapd-initd slapd
		newconfd "${FILESDIR}"/slapd-confd slapd
		if [ $(get_libdir) != lib ]; then
			sed -e "s,/usr/lib/,/usr/$(get_libdir)/," -i "${ED}"etc/init.d/{slapd,slurpd}
		fi
	fi
}

pkg_preinst() {
	# keep old libs if any
	preserve_old_lib
	usr/$(get_libdir)/{liblber,libldap,libldap_r}-2.3$(get_libname 0)
}

pkg_postinst() {
	if ! use minimal ; then
		# You cannot build SSL certificates during src_install that will make
		# binary packages containing your SSL key, which is both a security risk
		# and a misconfiguration if multiple machines use the same key and cert.
		if use ssl; then
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

	elog "Getting started using OpenLDAP? There is some documentation available:"
	elog "Gentoo Guide to OpenLDAP Authentication"
	elog "(http://www.gentoo.org/doc/en/ldap-howto.xml)"
	elog "---"
	elog "An example file for tuning BDB backends with openldap is"
	elog "DB_CONFIG.fast.example in /usr/share/doc/${PF}/"

	preserve_old_lib_notify
	usr/$(get_libdir)/{liblber,libldap,libldap_r}-2.3$(get_libname 0)
}
