# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/openafs/openafs-1.4.7.ebuild,v 1.4 2010/02/06 10:50:02 ulm Exp $

inherit flag-o-matic eutils toolchain-funcs versionator pam

PATCHVER=0.14
DESCRIPTION="The OpenAFS distributed file system"
HOMEPAGE="http://www.openafs.org/"
SRC_URI="http://openafs.org/dl/${PV}/${P}-src.tar.bz2
	doc? ( http://openafs.org/dl/${PV}/${P}-doc.tar.bz2 )
	mirror://gentoo/${PN}-gentoo-${PATCHVER}.tar.bz2"

LICENSE="IBM BSD openafs-krb5-a APSL-2 sun-rpc"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug kerberos pam doc"

RDEPEND="~net-fs/openafs-kernel-${PV}
	pam? ( sys-libs/pam )
	kerberos? ( virtual/krb5 )"

PATCHDIR=${WORKDIR}/gentoo/patches/$(get_version_component_range 1-2)
CONFDIR=${WORKDIR}/gentoo/configs
SCRIPTDIR=${WORKDIR}/gentoo/scripts

src_unpack() {
	unpack ${A}; cd "${S}"

	# Apply patches to apply chosen compiler settings, fix the hardcoded paths
	# to be more FHS friendly, and the fix the incorrect typecasts for va_arg
	EPATCH_EXCLUDE="006_all_ppc64.patch" \
	EPATCH_SUFFIX="patch" epatch ${PATCHDIR}

	# don't use mapfiles to strip symbols (bug #202489)
	epatch "${FILESDIR}"/openafs-1.4.5-shared-libs.patch
	# use uname i.o. arch (bug #211378)
	epatch "${FILESDIR}"/openafs-1.4.7-uname.patch

	# disable XCFLAGS override
	sed -i 's/^[ \t]*XCFLAGS.*/:/' src/cf/osconf.m4
	# disable compiler choice override
	sed -i 's/^[ \t]\+\(CC\|CCOBJ\|MT_CC\)="[^ ]*\(.*\)"/\1="${CC}\2"/' src/cf/osconf.m4

	# fix autoconf cludge (bug #218234)
	sed -i 's/^AC_\(AIX\|MINIX\)$//' acinclude.m4

	./regen.sh || die "Failed: regenerating configure script"
}

src_compile() {
	# cannot use "use_with" macro, as --without-krb5-config crashes the econf
	local myconf=""
	if use kerberos; then
		myconf="--with-krb5-conf=$(type -p krb5-config)"
	fi

	# AFS_SYSKVERS: fix linux version at 2.6
	AFS_SYSKVERS=26 \
	XCFLAGS="${CFLAGS}" \
	econf \
		$(use_enable pam) \
		$(use_enable debug) \
		--enable-largefile-fileserver \
		--enable-supergroups \
		--disable-kernel-module \
		${myconf} || die econf

	emake -j1 all_nolibafs || die "Build failed"
}

src_install() {
	make DESTDIR="${D}" install_nolibafs || die "Installing failed"

	# pam_afs and pam_afs.krb have been installed in irregular locations, fix
	if use pam; then
		dopammod "${ED}"/usr/$(get_libdir)/pam_afs*
		rm -f "${ED}"/usr/$(get_libdir)/pam_afs*
	fi

	# compile_et collides with com_err.  Remove it from this package.
	rm "${ED}"/usr/bin/compile_et

	# avoid collision with mit_krb5's version of kpasswd
	(cd "${ED}"/usr/bin; mv kpasswd kpasswd_afs)
	use doc && (cd "${ED}"/usr/share/man/man1; mv kpasswd.1 kpasswd_afs.1)

	# minimal documentation
	dodoc ${CONFDIR}/README ${CONFDIR}/CellServDB

	# documentation package
	if use doc; then
		use pam && doman src/pam/pam_afs.5

		cp -pPR doc/* "${ED}"/usr/share/doc/${PF}
	fi

	# Gentoo related scripts
	newconfd ${CONFDIR}/openafs-client openafs-client
	newconfd ${CONFDIR}/openafs-server openafs-server
	newinitd ${SCRIPTDIR}/openafs-client openafs-client
	newinitd ${SCRIPTDIR}/openafs-server openafs-server

	# used directories: client
	keepdir /etc/openafs
	keepdir /var/cache/openafs

	# used directories: server
	keepdir /etc/openafs/server
	diropts -m0700
	keepdir /var/lib/openafs
	keepdir /var/lib/openafs/db
	diropts -m0755
	keepdir /var/lib/openafs/logs

	# link logfiles to /var/log
	dosym ../lib/openafs/logs /var/log/openafs
}

pkg_preinst() {
	## Somewhat intelligently install default configuration files
	## (when they are not present)
	# CellServDB
	if [ ! -e "${EROOT}"etc/openafs/CellServDB ] \
		|| grep "GCO Public CellServDB" "${EROOT}"etc/openafs/CellServDB &> /dev/null
	then
		cp ${CONFDIR}/CellServDB "${ED}"etc/openafs
	fi
	# cacheinfo: use a default location cache, 200 megabyte in size
	# (should be safe for about any root partition, the user can increase
	# the size as required)
	if [ ! -e "${EROOT}"etc/openafs/cacheinfo ]; then
		echo "/afs:/var/cache/openafs:200000" > "${ED}"etc/openafs/cacheinfo
	fi
	# ThisCell: default to "openafs.org"
	if [ ! -e "${EROOT}"etc/openafs/ThisCell ]; then
		echo "openafs.org" > "${ED}"etc/openafs/ThisCell
	fi
}

pkg_postinst() {
	elog
	elog "This installation should work out of the box (at least the"
	elog "client part doing global afs-cell browsing, unless you had"
	elog "a previous and different configuration).  If you want to"
	elog "set up your own cell or modify the standard config,"
	elog "please have a look at the Gentoo OpenAFS documentation"
	elog "(warning: it is not yet up to date wrt the new file locations)"
	elog
	elog "The documentation can be found at:"
	elog "  http://www.gentoo.org/doc/en/openafs.xml"
}
