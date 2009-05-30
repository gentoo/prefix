# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdrtools/cdrtools-2.01.01_alpha53.ebuild,v 1.2 2009/05/28 15:28:35 ssuominen Exp $

inherit multilib eutils toolchain-funcs flag-o-matic

DESCRIPTION="A set of tools for CD/DVD reading and recording, including cdrecord"
HOMEPAGE="http://cdrecord.berlios.de/"
SRC_URI="ftp://ftp.berlios.de/pub/cdrecord/alpha/${P/_alpha/a}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="unicode"

DEPEND="sys-apps/acl
	!app-cdr/dvdrtools
	!app-cdr/cdrkit"

S=${WORKDIR}/${PN}-2.01.01

src_unpack() {
	unpack ${A}
	cd "${S}"

	#Adjust paths

	sed -i -e 's:opt/schily:usr:' \
		$(grep -l --include='*.1' --include='*.8' -r 'opt/schily' .) \
		$(grep -l --include='*.c' --include='*.h' -r 'opt/schily' .) \
		|| die "404 on opt-schily sed"

	sed -i -e "s:\(^INSDIR=\t\tshare/doc/\):\1${PF}/:" \
		$(grep -l -r 'INSDIR.\+doc' .) \
		|| die "404 on doc sed"

	sed -i -e "s:\(^INSDIR=\t\t\)lib:\1$(get_libdir):" \
		$(grep -l -r '^INSDIR.\+lib\(/siconv\)\?$' .) \
		|| die "404 on multilib-sed"

	sed -i -e "s:\(^INSDIR=\t\t\)\(etc/default\):\1../\2:" \
		$(grep -l -r '^INSDIR.\+default' .) \
		|| die "404 on etc sed"

	#Remove profiled make files
	rm -f $(find . -name '*_p.mk')

	epatch "${FILESDIR}"/${PN}-2.01.01a03-warnings.patch
	epatch "${FILESDIR}"/${PN}-2.01.01_alpha50-asneeded.patch

	#Schily make setup
	cd "${S}"/DEFAULTS
	local MYARCH="linux"
	[[ ${CHOST} == *-darwin* ]] && MYARCH="mac-os10"

	sed -i "s:/opt/schily:/usr:g" Defaults.${MYARCH}
	sed -i "s:/usr/src/linux/include::g" Defaults.${MYARCH}

	# For dynamic linking:
	sed -i "s:static:dynamic:" Defaults.${MYARCH}

	# lame symlinks that all point to the same thing
	cd "${S}"/RULES
	local t
	for t in ppc64 sh4 s390x ; do
		ln -s i586-linux-cc.rul ${t}-linux-cc.rul || die
		ln -s i586-linux-gcc.rul ${t}-linux-gcc.rul || die
	done

}

src_compile() {
	if use unicode; then
		local flags="$(test-flags -finput-charset=ISO-8859-1 -fexec-charset=UTF-8)"
		if [[ -n ${flags} ]]; then
			append-flags ${flags}
		else
			ewarn "Your compiler does not support the options required to build"
			ewarn "cdrtools with unicode in USE. unicode flag will be ignored."
		fi
	fi

	#If not built with -j1, "sometimes" cdda2wav will not be built. Nasty bug.
	emake -j1 CC="$(tc-getCC) -D__attribute_const__=const" COPTX="${CFLAGS}" CPPOPTX="${CPPFLAGS}" LDOPTX="${LDFLAGS}" || die
}

src_install() {
	make MANDIR="share/man" INS_BASE="${D}/usr/" install

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
