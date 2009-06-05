# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-doc/doxygen/doxygen-1.5.7.1.ebuild,v 1.4 2009/05/30 08:19:53 ulm Exp $

EAPI=1

inherit eutils flag-o-matic toolchain-funcs qt3 fdo-mime

DESCRIPTION="documentation system for C++, C, Java, Objective-C, Python, IDL, and other languages"
HOMEPAGE="http://www.doxygen.org/"
SRC_URI="ftp://ftp.stack.nl/pub/users/dimitri/${P}.src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="debug doc nodot qt3 latex elibc_FreeBSD"

RDEPEND="qt3? ( x11-libs/qt:3 )
	latex? ( app-text/texlive-core
		dev-texlive/texlive-genericrecommended
		dev-texlive/texlive-fontsrecommended
		dev-texlive/texlive-latexrecommended
		dev-texlive/texlive-latexextra )
	dev-lang/python
	virtual/libiconv
	media-libs/libpng
	virtual/ghostscript
	!nodot? ( >=media-gfx/graphviz-2.6
		media-libs/freetype )"
DEPEND=">=sys-apps/sed-4
	sys-devel/flex
	${RDEPEND}"

EPATCH_SUFFIX="patch"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# use CFLAGS, CXXFLAGS, LDFLAGS
	sed -i.orig -e 's:^\(TMAKE_CFLAGS_RELEASE\t*\)= .*$:\1= $(ECFLAGS):' \
		-e 's:^\(TMAKE_CXXFLAGS_RELEASE\t*\)= .*$:\1= $(ECXXFLAGS):' \
		-e 's:^\(TMAKE_LFLAGS_RELEASE\s*\)=.*$:\1= $(ELDFLAGS):' \
		tmake/lib/{{linux,freebsd,netbsd,openbsd,solaris}-g++,macosx-c++}/tmake.conf \
		|| die "sed failed"

	# Ensure we link to -liconv
	if use elibc_FreeBSD; then
		for pro in */*.pro.in */*/*.pro.in; do
		echo "unix:LIBS += -liconv" >> "${pro}"
		done
	fi

	# Consolidate patches, apply FreeBSD configure patch, codepage patch,
	# qtools stuff, and patches for bugs 129142, 121770, and 129560.
	epatch "${FILESDIR}/${PN}-1.5-legacy-patches.diff"
	epatch "${FILESDIR}/${P}-substitute.patch"

	# prefix search tools patch, plus OSX fixes
	epatch "${FILESDIR}"/${PN}-1.5.6-prefix-misc-alt.patch
	epatch "${FILESDIR}"/${PN}-1.5.7-prefix-libiconv.patch

	# remove internal libpng - see bug #210237
	epatch "${FILESDIR}/${PN}-1.5-system-libpng.patch"

	if [ $(get_libdir) == "lib64" ] ; then
		epatch "${FILESDIR}/${PN}-1.5-qtlibdir.patch"
	fi

	# fix final DESTDIR issue
	sed -i.orig -e "s:\$(INSTALL):\$(DESTDIR)/\$(INSTALL):g" \
		addon/doxywizard/Makefile.in || die "sed failed"

	if is-flagq "-O3" ; then
		echo
		ewarn "Compiling with -O3 is known to produce incorrectly"
		ewarn "optimized code which breaks doxygen."
		echo
		epause 6
		elog "Continuing with -O2 instead ..."
		echo
		replace-flags "-O3" "-O2"
	fi
}

src_compile() {
	export ECFLAGS="${CFLAGS}" ECXXFLAGS="${CXXFLAGS}" ELDFLAGS="${LDFLAGS}"
	# set ./configure options (prefix, Qt based wizard, docdir)

	local my_conf=""
	if use debug; then
		my_conf="--prefix ${EPREFIX}/usr --debug"
	else
		my_conf="--prefix ${EPREFIX}/usr"
	fi

	if use qt3; then
		einfo "using QTDIR: '$QTDIR'."
		export LIBRARY_PATH="${QTDIR}/$(get_libdir):${LIBRARY_PATH}"
		export LD_LIBRARY_PATH="${QTDIR}/$(get_libdir):${LD_LIBRARY_PATH}"
		einfo "using QT LIBRARY_PATH: '$LIBRARY_PATH'."
		einfo "using QT LD_LIBRARY_PATH: '$LD_LIBRARY_PATH'."
		./configure ${my_conf} $(use_with qt3 doxywizard) \
		|| die 'configure with qt3 failed'
	else
		./configure ${my_conf} || die 'configure failed'
	fi

	# and compile
	emake CC="$(tc-getCC)" CXX="$(tc-getCXX)" LINK="$(tc-getCXX)" \
		LINK_SHLIB="$(tc-getCXX)" all || die 'emake failed'

	# generate html and pdf (if tetex in use) documents.
	# errors here are not considered fatal, hence the ewarn message
	# TeX's font caching in /var/cache/fonts causes sandbox warnings,
	# so we allow it.
	if use doc; then
		if use nodot; then
		sed -i -e "s/HAVE_DOT               = YES/HAVE_DOT    = NO/" \
			{Doxyfile,doc/Doxyfile} || ewarn "disabling dot failed"
		fi
		if use latex; then
		addwrite /var/cache/fonts
		addwrite /var/cache/fontconfig
		addwrite /usr/share/texmf/fonts/pk
		addwrite /usr/share/texmf/ls-R
		make pdf || ewarn '"make pdf docs" failed.'
		else
		cp doc/Doxyfile doc/Doxyfile.orig
		cp doc/Makefile doc/Makefile.orig
		sed -i.orig -e "s/GENERATE_LATEX    = YES/GENERATE_LATEX    = NO/" \
			doc/Doxyfile
		sed -i.orig -e "s/@epstopdf/# @epstopdf/" \
			-e "s/@cp Makefile.latex/# @cp Makefile.latex/" \
			-e "s/@sed/# @sed/" doc/Makefile
		make docs || ewarn '"make html docs" failed.'
		fi
	fi
}

src_install() {
	make DESTDIR="${D}" MAN1DIR=share/man/man1 \
		install || die '"make install" failed.'

	if use qt3; then
		doicon "${FILESDIR}"/doxywizard.png
		make_desktop_entry doxywizard "DoxyWizard ${PV}" \
		"doxywizard.png" "Application;Development"
	fi

	dodoc INSTALL LANGUAGE.HOWTO README

	# pdf and html manuals
	if use doc; then
		insinto /usr/share/doc/"${PF}"
		if use latex; then
		doins latex/doxygen_manual.pdf
		fi
		dohtml -r html/*
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update

	elog
	elog "The USE flags qt3, doc, and latex will enable doxywizard, or"
	elog "the html and pdf documentation, respectively.  For examples"
	elog "and other goodies, see the source tarball.  For some example"
	elog "output, run doxygen on the doxygen source using the Doxyfile"
	elog "provided in the top-level source dir."
	elog
	elog "Enabling the nodot USE flag will remove the GraphViz dependency,"
	elog "along with Doxygen's ability to generate diagrams in the docs."
	elog "See the Doxygen homepage for additional helper tools to parse"
	elog "more languages."
	elog
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
