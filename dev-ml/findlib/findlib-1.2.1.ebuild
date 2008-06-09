# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/findlib/findlib-1.2.1.ebuild,v 1.12 2008/06/07 16:31:47 aballier Exp $

inherit multilib eutils

EAPI="prefix 1"

IUSE="doc +ocamlopt tk"

RESTRICT="installsources"

DESCRIPTION="OCaml tool to find/use non-standard packages."
HOMEPAGE="http://projects.camlcity.org/projects/findlib.html"
SRC_URI="http://download.camlcity.org/download/${P}.tar.gz"

LICENSE="MIT X11"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND=">=dev-lang/ocaml-3.07"

ocamlfind_destdir="${EPREFIX}/usr/$(get_libdir)/ocaml/site-packages"
stublibs="${ocamlfind_destdir}/stublibs"

pkg_setup()
{
	if ( use tk && ! built_with_use dev-lang/ocaml tk ); then
		eerror "It seems you don't have ocaml compiled with tk support"
		eerror ""
		eerror "The findlib toolbox requires ocaml be built with tk support."
		eerror ""
		die "Please make sure that ocaml is installed with tk support or remove the USE flag"
	fi
	if use ocamlopt && ! built_with_use --missing true dev-lang/ocaml ocamlopt; then
		eerror "In order to build ${PN} with native code support from ocaml"
		eerror "You first need to have a native code ocaml compiler."
		eerror "You need to install dev-lang/ocaml with ocamlopt useflag on."
		die "Please install ocaml with ocamlopt useflag"
	fi
}

src_compile() {
	local myconf
	use tk && myconf="-with-toolbox"
	./configure -bindir "${EPREFIX}"/usr/bin -mandir "${EPREFIX}"/usr/share/man \
		-sitelib ${ocamlfind_destdir} \
		-config ${ocamlfind_destdir}/findlib/findlib.conf \
		${myconf} || die "configure failed"

	emake all || die
	if use ocamlopt; then
		emake opt || die # optimized code
	else
		# If using bytecode we dont want to strip the binary as it would remove the
		# bytecode and only leave ocamlrun...
		export STRIP_MASK="*/bin/*"
	fi
}

src_install() {
	# makes double prefix, and appears not to be necessary
	#dodir `ocamlc -where`

	emake prefix="${D}" install || die

	dodir "${stublibs#${EPREFIX}}"

	cd "${S}/doc"
	dodoc QUICKSTART README DOCINFO
	use doc && dohtml -r ref-html guide-html
}

check_stublibs() {
	local ocaml_stdlib=`ocamlc -where`
	local ldconf="${ocaml_stdlib}/ld.conf"

	if [ ! -e ${ldconf} ]
	then
		echo "${ocaml_stdlib}" > ${ldconf}
		echo "${ocaml_stdlib}/stublibs" >> ${ldconf}
	fi

	if [ -z `grep -e ${stublibs} ${ldconf}` ]
	then
		echo ${stublibs} >> ${ldconf}
	fi
}

pkg_postinst() {
	check_stublibs
}
