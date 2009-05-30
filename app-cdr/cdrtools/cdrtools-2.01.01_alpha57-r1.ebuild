# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdrtools/cdrtools-2.01.01_alpha57-r1.ebuild,v 1.7 2009/05/28 15:28:35 ssuominen Exp $

EAPI=2

inherit multilib eutils toolchain-funcs flag-o-matic

DESCRIPTION="A set of tools for CD/DVD reading and recording, including cdrecord"
HOMEPAGE="http://cdrecord.berlios.de/"
SRC_URI="ftp://ftp.berlios.de/pub/cdrecord/alpha/${P/_alpha/a}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="unicode acl"

DEPEND="acl? ( sys-apps/acl )
	!app-cdr/dvdrtools
	!app-cdr/cdrkit"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}-2.01.01

src_prepare() {
	#"Adjust paths. Upstream is clearly on drugs, hardcoding paths into .c files.
	sed -i -e 's:opt/schily:usr:' \
		$(grep -l --include='*.1' --include='*.8' -r 'opt/schily' .) \
		$(grep -l --include='*.c' --include='*.h' -r 'opt/schily' .) \
		|| die "404 on opt-schily sed"

	sed -i -e "s:\(^INSDIR=\t\tshare/doc/\):\1${PF}/:" \
		$(grep -l -r 'INSDIR.\+doc' .) \
		|| die "404 on doc sed"

	# Upstream should be hanged from the yardarm, possibly keelhauled for
	# not respecting libdir.
	sed -i -e "s:\(^INSDIR=\t\t\)lib:\1$(get_libdir):" \
		$(grep -l -r '^INSDIR.\+lib\(/siconv\)\?$' .) \
		|| die "404 on multilib-sed"

	# See previous comment s/libdir/--disable-static/
	sed -i -e 's:include\t\t.*rules.lib::' \
		$(grep -l -r '^include.\+rules\.lib' .) \
		|| die "404 on rules sed"
	#Remove profiled make files (wtf?)
	rm -f $(find . -name '*_p.mk') || die "rm failed"

	epatch "${FILESDIR}"/${PN}-2.01.01a03-warnings.patch
	epatch "${FILESDIR}"/${PN}-2.01.01_alpha50-asneeded.patch

	#Schily make setup
	cd "${S}"/DEFAULTS
	local MYARCH="linux"
	[[ ${CHOST} == *-darwin* ]] && MYARCH="mac-os10"

	sed -i "s:/opt/schily:/usr:g" Defaults.${MYARCH} || die "sed schily-opt failed"
	sed -i "s:/usr/src/linux/include::g" Defaults.${MYARCH} || die "sed linux-include failed"
	sed -i "/RUNPATH/ c\RUNPATH= " Defaults.${MYARCH} || die "sed RUNPATH failed"

	# For dynamic linking:
	sed -i "s:static:dynamic:" Defaults.${MYARCH} || die "sed static-remove failed"

	# lame symlinks that all point to the same thing
	cd "${S}"/RULES
	local t
	for t in ppc64 sh4 s390x ; do
		ln -s i586-linux-cc.rul ${t}-linux-cc.rul || die
		ln -s i586-linux-gcc.rul ${t}-linux-gcc.rul || die
	done
}

src_configure() { : ; }

src_compile() {
	local ACL="-lacl"
	if use unicode; then
		local flags="$(test-flags -finput-charset=ISO-8859-1 -fexec-charset=UTF-8)"
		if [[ -n ${flags} ]]; then
			append-flags ${flags}
		else
			ewarn "Your compiler does not support the options required to build"
			ewarn "cdrtools with unicode in USE. unicode flag will be ignored."
		fi
	fi

	if ! use acl
	then
		CFLAGS="${CFLAGS} -DNO_ACL"
		ACL=""
	fi
	#If not built with -j1, "sometimes" cdda2wav will not be built. Nasty bug.
	emake -j1 CC="$(tc-getCC) -D__attribute_const__=const" COPTX="${CFLAGS}" LIB_ACL_TEST="${ACL}" CPPOPTX="${CPPFLAGS}" LDOPTX="${LDFLAGS}" || die "emake failed"
}

src_install() {
	emake -j1 MANDIR="share/man" INS_BASE="${D}/usr/" INS_RBASE="${D}" install

	#These symlinks are for compat with cdrkit.
	dosym schily /usr/include/scsilib
	dosym ../scg /usr/include/schily/scg

	dodoc ABOUT Changelog README README.linux-shm START READMEs/README.linux || die "dodoc cdrtools"

	cd "${S}"/cdda2wav
	docinto cdda2wav
	dodoc FAQ Frontends HOWTOUSE TODO || die "dodoc cdda2wav"

}

pkg_postinst() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		einfo
		einfo "Darwin/OS X use the following device names:"
		einfo
		einfo "CD burners: (probably) ./cdrecord dev=IOCompactDiscServices"
		einfo
		einfo "DVD burners: (probably) ./cdrecord dev=IODVDServices"
		einfo
	else
	echo
	einfo "The command line option 'dev=/dev/hdX' (X is the name of your drive)"
	einfo "should be used for IDE CD writers.  And make sure that the permissions"
	einfo "on this device are set properly and your user is in the correct group."
	fi
}
