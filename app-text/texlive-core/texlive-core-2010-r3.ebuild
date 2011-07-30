# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/texlive-core/texlive-core-2010-r3.ebuild,v 1.1 2011/07/06 20:41:51 aballier Exp $

EAPI=3

inherit eutils flag-o-matic toolchain-funcs libtool texlive-common prefix

PATCHLEVEL="25"
TL_SOURCE_VERSION=20100722
MY_PV=${PN%-core}-${TL_SOURCE_VERSION}-source

DESCRIPTION="A complete TeX distribution"
HOMEPAGE="http://tug.org/texlive/"
SLOT="0"
LICENSE="GPL-2 LPPL-1.3c TeX"

SRC_URI="mirror://gentoo/${MY_PV}.tar.xz"

# Fetch patches
SRC_URI="${SRC_URI} mirror://gentoo/${PN}-patches-${PATCHLEVEL}.tar.xz"

TL_CORE_BINEXTRA_MODULES="a2ping asymptote bibtex8 bundledoc ctie cweb de-macro dtl dvi2tty dviasm dvicopy dvidvi dviljk dvipng dvipos findhyph fragmaster hyphenex installfont lacheck latex2man listings-ext mkjobtexmf patgen pdfcrop pdftools pkfix pkfix-helper purifyeps seetexk synctex texcount texdiff texdirflatten texdoc texloganalyser texware tie tpic2pdftex web collection-binextra"
TL_CORE_BINEXTRA_DOC_MODULES="
a2ping.doc asymptote.doc bibtex8.doc bundledoc.doc ctie.doc cweb.doc de-macro.doc dvicopy.doc dviljk.doc dvipng.doc dvipos.doc findhyph.doc fragmaster.doc installfont.doc latex2man.doc listings-ext.doc mkjobtexmf.doc patgen.doc pdfcrop.doc pdftools.doc pkfix.doc pkfix-helper.doc purifyeps.doc synctex.doc texcount.doc texdiff.doc texdirflatten.doc texdoc.doc texloganalyser.doc texware.doc tie.doc tpic2pdftex.doc web.doc
"
TL_CORE_BINEXTRA_SRC_MODULES="hyphenex.source listings-ext.source mkjobtexmf.source"

TL_CORE_EXTRA_MODULES="tetex hyphen-base texconfig gsftopk ${TL_CORE_BINEXTRA_MODULES}"
TL_CORE_EXTRA_DOC_MODULES="tetex.doc texconfig.doc gsftopk.doc ${TL_CORE_BINEXTRA_DOC_MODULES}"
TL_CORE_EXTRA_SRC_MODULES="${TL_CORE_BINEXTRA_SRC_MODULES}"

for i in ${TL_CORE_EXTRA_MODULES}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.tar.xz"
done

SRC_URI="${SRC_URI} doc? ( "
for i in ${TL_CORE_EXTRA_DOC_MODULES}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.tar.xz"
done
SRC_URI="${SRC_URI} )"
SRC_URI="${SRC_URI} source? ( "
for i in ${TL_CORE_EXTRA_SRC_MODULES}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.tar.xz"
done
SRC_URI="${SRC_URI} )"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="cjk X doc source tk xetex"

MODULAR_X_DEPEND="X? (
				x11-libs/libXmu
				x11-libs/libXp
				x11-libs/libXpm
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libXaw
				x11-libs/libXfont
	)"

COMMON_DEPEND="${MODULAR_X_DEPEND}
	!app-text/ptex
	!app-text/tetex
	!<app-text/texlive-2007
	!app-text/xetex
	!<dev-texlive/texlive-basic-2009
	!app-text/dvibook
	sys-libs/zlib
	>=media-libs/libpng-1.2.43-r2:0
	>=app-text/poppler-0.12.3-r3
	xetex? (
		app-text/teckit
		media-libs/fontconfig
		media-libs/freetype:2
		media-libs/silgraphite
	)
	>=dev-libs/kpathsea-6.0.1_p20110627
	cjk? ( dev-libs/ptexenc )"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig
	sys-apps/ed
	sys-devel/flex
	app-arch/xz-utils"

RDEPEND="${COMMON_DEPEND}
	app-text/ps2pkm
	app-text/dvipsk
	dev-tex/bibtexu
	xetex? ( >=app-text/xdvipdfmx-0.7.8 )
	tk? ( dev-perl/perl-tk )"

# texdoc needs luatex.
PDEPEND=">=dev-tex/luatex-0.63"

S="${WORKDIR}/${MY_PV}"

src_prepare() {
	mv "${WORKDIR}"/texmf* "${S}" || die "failed to move texmf files"

	cp "${FILESDIR}"/texmf-update2010 "${T}" || die
	cd "${T}"; epatch "${FILESDIR}"/texmf-update2010-prefix.patch; cd "${S}"
	eprefixify "${T}"/texmf-update2010

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/patches"

	# don't use deprecated interfaces from MacFreetype
#	epatch "${FILESDIR}"/2009/${PN}-2009-nomacfreetype.patch

	elibtoolize
}

src_configure() {
	# Too many regexps use A-Z a-z constructs, what causes problems with locales
	# that don't have the same alphabetical order than ascii. Bug #242430
	# So we set LC_ALL to C in order to avoid problems.
	export LC_ALL=C
	tc-export CC CXX AR

	export CONFIG_SHELL="${EPREFIX}"/bin/bash

	econf -C \
		--bindir="${EPREFIX}"/usr/bin \
		--datadir="${S}" \
		--with-system-freetype2 \
		--with-freetype2-include="${EPREFIX}"/usr/include/freetype2 \
		--with-freetype2-libdir="${EPREFIX}"/usr/lib \
		--with-system-zlib \
		--with-system-libpng \
		--with-system-xpdf \
		--with-system-teckit \
		--with-teckit-includes="${EPREFIX}"/usr/include/teckit \
		--with-system-graphite \
		--with-system-kpathsea \
		--with-kpathsea-includes="${EPREFIX}"/usr/include \
		--with-system-icu \
		--with-system-ptexenc \
		--without-texinfo \
		--disable-dialog \
		--disable-multiplatform \
		--enable-epsfwin \
		--enable-mftalkwin \
		--enable-regiswin \
		--enable-tektronixwin \
		--enable-unitermwin \
		--with-ps=gs \
		--disable-psutils \
		--disable-t1utils \
		--enable-ipc \
		--disable-bibtexu \
		--disable-dvipng \
		--disable-dvipsk \
		--disable-dvipdfmx \
		--disable-chktex \
		--disable-lcdf-typetools \
		--disable-pdfopen \
		--disable-ps2eps \
		--disable-ps2pkm \
		--disable-detex \
		--disable-ttf2pk \
		--disable-tex4htk \
		--disable-cjkutils \
		--disable-xdvik \
		--disable-xindy \
		--disable-luatex \
		--disable-dvi2tty \
		--disable-dvisvgm \
		--disable-vlna \
		--disable-xdvipdfmx \
		--enable-shared \
		--disable-native-texlive-build \
		--disable-largefile \
		$(use_enable xetex) \
		$(use_enable cjk ptex) \
		$(use_enable cjk mendexk) \
		$(use_enable cjk makejvf) \
		$(use_with X x)
}

src_compile() {
	emake SHELL="${EPREFIX}"/bin/sh texmf="${EPREFIX}"${TEXMF_PATH:-/usr/share/texmf} || die "emake failed"

	# Mimic updmap --syncwithtrees to enable only fonts installed
	# Code copied from updmap script
	for i in `egrep '^(Mixed)?Map' "texmf/web2c/updmap.cfg" | sed 's@.* @@'`; do
		texlive-common_is_file_present_in_texmf "$i" || echo "$i"
	done > "${T}/updmap_update"
	{
		sed 's@/@\\/@g; s@^@/^MixedMap[     ]*@; s@$@$/s/^/#! /@' <"${T}/updmap_update"
		sed 's@/@\\/@g; s@^@/^Map[  ]*@; s@$@$/s/^/#! /@' <"${T}/updmap_update"
	} > "${T}/updmap_update2"
	sed -f "${T}/updmap_update2" "texmf/web2c/updmap.cfg" >	"${T}/updmap_update3"\
		&& cat "${T}/updmap_update3" > "texmf/web2c/updmap.cfg"
}

src_test() {
	ewarn "Due to modular layout of texlive ebuilds,"
	ewarn "It would not make much sense to use tests into the ebuild"
	ewarn "And tests would fail anyway"
	ewarn "Alternatively you can try to compile any tex file"
	ewarn "Tex warnings should be considered as errors and reported"
	ewarn "You can also run fmtutil-sys --all and check for errors/warnings there"
}

src_install() {
	dodir ${TEXMF_PATH:-/usr/share/texmf}/web2c
	emake DESTDIR="${D}" texmf="${ED}${TEXMF_PATH:-/usr/share/texmf}" run_texlinks="true" run_mktexlsr="true" install || die "install failed"

	dodir /usr/share # just in case
	cp -pR texmf{,-dist} "${ED}/usr/share/" || die "failed to install texmf trees"
	if use source ; then
		cp -pR "${WORKDIR}"/tlpkg "${ED}/usr/share/" || die "failed to install tlpkg files"
	fi

	newsbin "${T}/texmf-update2010" texmf-update

	# When X is disabled mf-nowin doesn't exist but some scripts expect it to
	# exist. Instead, it is called mf, so we symlink it to please everything.
	use X || dosym mf /usr/bin/mf-nowin

	docinto texk
	cd "${S}/texk"
	dodoc ChangeLog README || die "failed to install texk docs"

	docinto dviljk
	cd "${S}/texk/dviljk"
	dodoc ChangeLog README NEWS || die "failed to install dviljk docs"

	docinto makeindexk
	cd "${S}/texk/makeindexk"
	dodoc ChangeLog NEWS NOTES README || die "failed to install makeindexk docs"

	docinto web2c
	cd "${S}/texk/web2c"
	dodoc ChangeLog NEWS PROJECTS README || die "failed to install web2c docs"

	use doc || rm -rf "${ED}/usr/share/texmf/doc"
	use doc || rm -rf "${ED}/usr/share/texmf-dist/doc"

	dodir /etc/env.d
	echo 'CONFIG_PROTECT_MASK="/etc/texmf/web2c /etc/texmf/language.dat.d /etc/texmf/language.def.d /etc/texmf/updmap.d"' > "${ED}/etc/env.d/98texlive"
	# populate /etc/texmf
	keepdir /etc/texmf/web2c

	# take care of updmap.cfg and language.d files
	keepdir /etc/texmf/{updmap.d,language.dat.d,language.def.d,language.dat.lua.d}

	mv "${ED}${TEXMF_PATH}/web2c/updmap.cfg"	"${ED}/etc/texmf/updmap.d/00updmap.cfg" || die "moving updmap.cfg failed"

	# Remove fmtutil.cnf, it will be regenerated from /etc/texmf/fmtutil.d files
	# by texmf-update
	rm -f "${ED}${TEXMF_PATH}/web2c/fmtutil.cnf"

	texlive-common_handle_config_files

	keepdir /usr/share/texmf-site

	dosym /etc/texmf/web2c/updmap.cfg ${TEXMF_PATH}/web2c/updmap.cfg

	# the virtex symlink is not installed
	# The links has to be relative, since the targets
	# is not present at this stage and MacOS doesn't
	# like non-existing targets
	dosym tex /usr/bin/virtex
	dosym pdftex /usr/bin/pdfvirtex

	# Remove texdoctk if we don't want it
	if ! use tk ; then
		rm -f "${ED}/usr/bin/texdoctk" "${ED}/usr/share/texmf/scripts/tetex/texdoctk.pl" "${ED}/usr/share/man/man1/texdoctk.1" || die "failed to remove texdoc tk!"
	fi

	# Rename mpost to leave room for mplib
	mv "${ED}/usr/bin/mpost" "${ED}/usr/bin/mpost-${P}"
	dosym "mpost-${P}" /usr/bin/mpost

	# Ditto for pdftex
	mv "${ED}/usr/bin/pdftex" "${ED}/usr/bin/pdftex-${P}"
	dosym "pdftex-${P}" /usr/bin/pdftex
}

pkg_preinst() {
	# Remove stray files to keep the upgrade path sane
	if has_version =app-text/texlive-core-2007* ; then
		for i in pdftex/pdflatex aleph/aleph aleph/lamed omega/lambda omega/omega xetex/xetex xetex/xelatex tex/tex pdftex/etex pdftex/pdftex pdftex/pdfetex ; do
			for j in log fmt ; do
				local file="${EROOT}/var/lib/texmf/web2c/${i}.${j}"
				if [ -f "${file}" ] ; then
					elog "Removing stray ${file} from TeXLive 2007 install."
					rm -f "${file}"
				fi
			done
		done
		for j in base log ; do
			local file="${EROOT}/var/lib/texmf/web2c/metafont/mf.${j}"
			if [ -f "${file}" ] ; then
				elog "Removing stray ${file} from TeXLive 2007 install."
				rm -f "${file}"
			fi
		done
	fi
}

pkg_postinst() {
	etexmf-update

	elog
	elog "If you have configuration files in ${EPREFIX}/etc/texmf to merge,"
	elog "please update them and run ${EPREFIX}/usr/sbin/texmf-update."
	elog
	ewarn "If you are migrating from an older TeX distribution"
	ewarn "Please make sure you have read:"
	ewarn "http://www.gentoo.org/proj/en/tex/texlive-migration-guide.xml"
	ewarn "in order to avoid possible problems"
	elog
	elog "TeXLive has been split in various ebuilds. If you are missing a"
	elog "package to process your TeX documents, you can install"
	elog "dev-tex/texmfind to easily search for them."
	elog
}
