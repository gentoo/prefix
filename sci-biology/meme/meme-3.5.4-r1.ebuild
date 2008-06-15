# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/meme/meme-3.5.4-r1.ebuild,v 1.4 2008/06/14 12:34:50 markusle Exp $

EAPI="prefix"

inherit autotools eutils toolchain-funcs

DESCRIPTION="The MEME/MAST system - Motif discovery and search"
HOMEPAGE="http://meme.sdsc.edu/meme"
SRC_URI="http://meme.nbcr.net/downloads/${PN}_${PV}.tar.gz"
LICENSE="meme"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
# Other possible USE flags include "debug", "client", "server", "web",
# "queue". Other variables must be set at compile time, but only when
# the Web server is built. Right now, Web server and client are disabled.
IUSE="mpi"

# Works only with LAM-MPI.
DEPEND=">=dev-lang/perl-5.6.1
	mpi? ( sys-cluster/lam-mpi )"

S="${WORKDIR}/${PN}_${PV}"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${P}-Makefile.am.patch"
	epatch "${FILESDIR}/${P}-patch1.patch"
	epatch "${FILESDIR}/${P}-patch2.patch"
	einfo "Regenerating autotools files..."
	eautoreconf
}

src_compile() {
	local EXTRA_CONF
	# Build system is too bugy to make the programs use standard locations.
	# Put everything in "/opt" instead.
	EXTRA_CONF="${EXTRA_CONF} --prefix=${EPREFIX}/opt/${PN}"
	EXTRA_CONF="${EXTRA_CONF} --with-logs=${EPREFIX}/var/log/${PN}"
	# Connect hyperlinks to official Web site.
	EXTRA_CONF="${EXTRA_CONF} --with-url=http://meme.nbcr.net/meme"
	# Disable Web server, client and Web site.
	EXTRA_CONF="${EXTRA_CONF} --disable-server --disable-client --disable-web"
	# Parallel implementation
	if ! use mpi; then
		EXTRA_CONF="${EXTRA_CONF} --enable-serial"
	fi

	./configure ${EXTRA_CONF} || die "Configure failed."
	CC="$(tc-getCC)" ac_cc_opt="${CFLAGS}"  make -e || die "Make failed."

# Install parallel files only on x86, otherwise the install fails with the error:
# i386 architecture of input file `mp.o' is incompatible with i386:x86-64 output
	if [[ "${ARCH}" == "x86" ]] ; then
		if use mpi; then
			cd src/parallel
			make || die "Parallel make failed."
		fi
	fi
}

src_install() {
	make install DESTDIR="${D}" || die "Failed to install program files."
	exeinto "/opt/${PN}/bin"
	if [[ "${ARCH}" == "x86" ]] ; then
		if use mpi; then
		doexe "${S}/src/parallel/${PN}_p" || \
			die "Failed to install parallel MEME implementation."
		fi
	fi
	keepdir "/var/log/${PN}"
	fperms 777 "/var/log/${PN}"
}

pkg_postinst() {
	echo
	einfo 'Prior to using MEME/MAST, you should source "/opt/meme/etc/meme.sh"'
	einfo '(or "/opt/meme/etc/meme.csh" if you use a csh-style shell). To do'
	einfo 'this automatically with bash, add the following statement to your'
	einfo '"~/.bashrc" file (without the quotes): "source /opt/meme/etc/meme.sh".'
	echo
	einfo 'Log files are produced in the "/var/log/meme" directory.'
	echo
}

src_test() {
	make test || die "Regression tests failed."
}
