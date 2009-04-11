# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/lam-mpi/lam-mpi-7.1.4-r1.ebuild,v 1.3 2009/03/02 20:26:34 ranger Exp $

inherit autotools eutils fortran flag-o-matic multilib portability

IUSE="crypt pbs fortran xmpi romio examples"

MY_P=${P/-mpi}
S=${WORKDIR}/${MY_P}

DESCRIPTION="the LAM MPI parallel computing environment"
SRC_URI="http://www.lam-mpi.org/download/files/${MY_P}.tar.bz2"
HOMEPAGE="http://www.lam-mpi.org"
DEPEND="pbs? ( sys-cluster/torque )
	!sys-cluster/mpich
	!sys-cluster/openmpi
	!sys-cluster/mpich2"

RDEPEND="${DEPEND}
	crypt? ( net-misc/openssh )
	!crypt? ( net-misc/netkit-rsh )"

SLOT="6"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="lam-mpi"

src_unpack() {
	unpack ${A}

	cd "${S}"/romio/util/
	sed -i "s|docdir=\"\$datadir/lam/doc\"|docdir=\"${ED}/usr/share/doc/${PF}\"|" romioinstall.in

	for i in "${S}"/share/memory/{ptmalloc,ptmalloc2,darwin7}/Makefile.in; do
	  sed -i -e 's@^\(docdir = \)\$(datadir)/lam/doc@\1'"${EPREFIX}"/usr/share/doc/${PF}'@' ${i}
	done

	cd "${S}"
	epatch "${FILESDIR}"/7.1.2-lam_prog_f77.m4.patch
	epatch "${FILESDIR}"/7.1.2-liblam-use-extra-libs.patch
	epatch "${FILESDIR}"/7.1.4-as-needed.patch

	if has_version '>=sys-devel/libtool-2.2'; then
		# Compatibility patch for the newer libtools, uses LT_INIT
		# which is not compatible with older versions.
		epatch "${FILESDIR}"/${PN}-7.1.4-libtool.patch
	fi

	# gcc-4.3.0 fix.  char *argv[] -> char **argv.
	# replaces a few more than necessary, but should be harmless.
	# TODO:  Already applied upstream, will be in 7.1.5
	for f in config/*.m4; do
		sed -i 's:^\(int main(int argc, char\)[^{]*\([{]\?\):\1** argv) \2:g' $f
	done

	# eautoreconf doesn't work correctly as lam-mpi uses their own
	# LAM_CONFIG_SUBDIR instead of AC_CONFIG_SUBDIRS.  Even better, they use
	# variables inside of the definitions, so --trace doesn't work.
	for f in $(find ./ -name 'configure.ac'); do
		pushd $(dirname $f) &>/dev/null
		eautoreconf
		popd &>/dev/null
	done
	eautoreconf
}

pkg_setup() {
	einfo
	elog "LAM/MPI is now in a maintenance mode. Bug fixes and critical patches"
	elog "are still being applied, but little real new work is happening in"
	elog "LAM/MPI. This is a direct result of the LAM/MPI Team spending the"
	elog "vast majority of their time working on our next-generation MPI"
	elog "implementation, http://www.openmpi.org"
	elog "  ---From the lam-mpi hompage.  Please consider upgrading."
	einfo
	# fortran_pkg_setup should -not- be run here.
}

src_compile() {

	local myconf

	if use crypt; then
		myconf="${myconf} --with-rsh=ssh"
	else
		myconf="${myconf} --with-rsh=rsh"
	fi

	if ! use pbs; then
		# See: http://www.lam-mpi.org/MailArchives/lam/2006/05/12445.php
		rm -rf "${S}"/share/ssi/boot/tm
	elif has_version "<=sys-cluster/torque-2.1.6"; then
		# Newer versions dropped the conflicting names and can
		# be installed to nice directories.
		append-ldflags -L/usr/$(get_libdir)/pbs/lib
	fi

	# Following the above post to the mailing list, we'll get
	# rid of bproc, globus and slurm as well, none of which are
	# in the current tree.
	rm -rf "${S}"/share/ssi/boot/{bproc,globus,slurm}

	if use fortran; then
		fortran_pkg_setup
		# this is NOT in pkg_setup as it is NOT needed for RDEPEND right away it
		# can be installed after merging from binary, and still have things fine
		myconf="${myconf} --with-fc=${FORTRANC}"
	else
		myconf="${myconf} --without-fc"
	fi

	econf \
		--with-ltdl-include=/usr/include \
		--with-ltdl-lib=/usr/$(get_libdir) \
		--disable-ltdl-install \
		$(use_with xmpi trillium) \
		--sysconfdir="${EPREFIX}"/etc/lam-mpi \
		--enable-shared \
		--with-threads=posix \
		$(use_with romio) \
		${myconf} || die "econf failed."
	emake || die "emake failed."
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"

	# With USE=xmpi /usr/bin/sweep is installed.  However it's just
	# a bash script to call bfctl -R and it causes file collisions
	# with media-sound/sweep.  Hence, we remove it, see man bfcfl.
	if [ -f "${ED}"/usr/bin/sweep ]; then
		rm -f "${ED}"/usr/bin/sweep || die
	fi

	# There are a bunch more tex docs we could make and install too,
	# but they are replicated in the pdfs!
	dodoc README HISTORY VERSION
	dodoc "${S}"/doc/{user,install}.pdf

	if use examples; then
		cd "${S}"/examples
		dodir /usr/share/${P}/examples
		find -name README -or -iregex '.*\.[chf][c]?$' >"${T}"/testlist
		while read p; do
			treecopy $p "${ED}"/usr/share/${P}/examples ;
		done < "${T}"/testlist
	fi
}
