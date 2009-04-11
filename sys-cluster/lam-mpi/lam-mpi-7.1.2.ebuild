# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/lam-mpi/lam-mpi-7.1.2.ebuild,v 1.17 2008/03/11 14:34:41 jsbronder Exp $

inherit autotools eutils fortran flag-o-matic multilib portability

# LAM is a PITA with PBS. If it's detected, there is NO way to turn it off!
# Likewise for the other SSI boot modules (globus/slurm/tm are affected)
IUSE="crypt pbs fortran xmpi"

MY_P=${P/-mpi}
S=${WORKDIR}/${MY_P}

DESCRIPTION="the LAM MPI parallel computing environment"
SRC_URI="http://www.lam-mpi.org/download/files/${MY_P}.tar.bz2"
HOMEPAGE="http://www.lam-mpi.org"
DEPEND="virtual/libc
	pbs? ( virtual/pbs )
	!sys-cluster/mpich
	!sys-cluster/openmpi
	!sys-cluster/mpich2"
# we need ssh if we want to use it instead of rsh
RDEPEND="${DEPEND}
	crypt? ( net-misc/openssh )
	!crypt? ( net-misc/netkit-rsh )"

SLOT="6"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="as-is"

src_unpack() {
	unpack ${A}

	cd "${S}"/romio/util/
	sed -i "s|docdir=\"\$datadir/lam/doc\"|docdir=\"${ED}/usr/share/doc/${PF}\"|" romioinstall.in

	for i in "${S}"/share/memory/{ptmalloc,ptmalloc2,darwin7}/Makefile.in; do
	  sed -i -e 's@^\(docdir = \)\$(datadir)/lam/doc@\1'"${EPREFIX}"/usr/share/doc/${PF}'@' ${i}
	done

	cd "${S}"
	epatch "${FILESDIR}"/${PV}-lam_prog_f77.m4.patch
	epatch "${FILESDIR}"/${PV}-liblam-use-extra-libs.patch
	eautoreconf
}

pkg_setup() {
	: # make sure fortran_pkg_setup does NOT run
}

src_compile() {

	local myconf

	if use crypt; then
		myconf="${myconf} --with-rsh=ssh"
	else
		myconf="${myconf} --with-rsh=rsh"
	fi

	use pbs && append-ldflags -L/usr/$(get_libdir)/pbs/lib

	if use fortran; then
		fortran_pkg_setup
		# this is NOT in pkg_setup as it is NOT needed for RDEPEND right away it
		# can be installed after merging from binary, and still have things fine
		myconf="${myconf} --with-fc=${FORTRANC}"
	else
		myconf="${myconf} --without-fc"
	fi

	econf \
		$(use_with xmpi trillium) \
		--sysconfdir="${EPREFIX}"/etc/lam-mpi \
		--enable-shared \
		--with-threads=posix \
		${myconf} || die
}

src_install () {

	make DESTDIR="${D}" install || die

	# There are a bunch more tex docs we could make and install too,
	# but they might be replicated in the pdf.
	# They are replicated in the pdfs! Thus remove this comment?
	dodoc README HISTORY VERSION
	cd "${S}"/doc
	dodoc {user,install}.pdf

	# install examples
	cd "${S}"/examples
	mkdir -p "${ED}"/usr/share/${P}/examples
	find -name README -or -iregex '.*\.[chf][c]?$' > "${T}"/testlist
	while read p; do
		treecopy $p "${ED}"/usr/share/${P}/examples ;
	done < "${T}"/testlist
}
