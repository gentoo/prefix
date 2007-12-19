# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/erlang/erlang-11.2.5-r3.ebuild,v 1.5 2007/12/18 07:53:20 opfer Exp $

EAPI="prefix"

inherit elisp-common eutils flag-o-matic multilib versionator

# NOTE: You	 need to adjust the version number	in the last comment.  If you need symlinks for
# binaries please tell maintainers or open up a bug to let it be created.

# erlang uses a really weird versioning scheme which caused quite a few problems
# already. Thus we do a slight modification converting all letters to digits to
# make it more sane (see e.g. #26420)

# the next line selects the right source.
MY_PV="R$(get_major_version)B-$(get_version_component_range 3)"

# ATTN!! Take care when processing the C, etc version!
MY_P=otp_src_${MY_PV}

DESCRIPTION="Erlang programming language, runtime environment, and large collection of libraries"
HOMEPAGE="http://www.erlang.org/"
SRC_URI="http://www.erlang.org/download/${MY_P}.tar.gz
	doc? ( http://erlang.org/download/otp_doc_man_${MY_PV}.tar.gz
		http://erlang.org/download/otp_doc_html_${MY_PV}.tar.gz )"

LICENSE="EPL"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"
IUSE="doc emacs hipe java kpoll odbc smp ssl tk"

RDEPEND=">=dev-lang/perl-5.6.1
	ssl? ( >=dev-libs/openssl-0.9.7d )
	emacs? ( virtual/emacs )
	java? ( >=virtual/jdk-1.2 )
	odbc? ( dev-db/unixODBC )"
DEPEND="${RDEPEND}
	tk? ( dev-lang/tk )"

S="${WORKDIR}/${MY_P}"

SITEFILE=50erlang-gentoo.el

src_unpack() {

	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-build.patch #184419

	# needed for amd64
	epatch "${FILESDIR}/${PN}-10.2.6-export-TARGET.patch"

	# needed for FreeBSD
	epatch "${FILESDIR}/${P}-gethostbyname.patch"

	# odbc is disabled in the amd64 code, but it works
	if use amd64 && use odbc; then
		epatch "${FILESDIR}/${P}-odbc-support-amd64.patch"
	fi

	# needed for building with hipe and recent coreutils
	use hipe && epatch "${FILESDIR}"/${P}-hipe.patch

	use odbc || sed -i 's: odbc : :' lib/Makefile

	# make sure we only link ssl dynamically
	sed -i '/SSL_DYNAMIC_ONLY=/s:no:yes:' erts/configure #184419

	if use hipe; then
		ewarn
		ewarn "You enabled High performance Erlang. Be aware that this extension"
		ewarn "can break the compilation in many ways, especially on hardened systems."
		ewarn "Don't cry, don't file bugs, just disable it!"
		ewarn
	fi
}

src_compile() {
	use java || export JAVAC=false

	local myconf=
	use ssl && myconf="--with-ssl=${EPREFIX}/usr" || myconf="--without-ssl"
	econf \
		--enable-threads \
		$(use_enable hipe) \
		"${myconf}" \
		$(use_enable kpoll kernell-poll) \
		$(use_enable smp smp-support) \
		|| die "econf failed"
	emake -j1 || die "emake failed"

	if use emacs ; then
		pushd lib/tools/emacs
		elisp-compile *.el
		popd
	fi
}

extract_version() {
	sed -n -e "/^$2 = \(.*\)$/s::\1:p" "${S}/$1/vsn.mk"
}

src_install() {
	local ERL_LIBDIR=/usr/$(get_libdir)/erlang
	local ERL_INTERFACE_VER=$(extract_version lib/erl_interface EI_VSN)
	local ERL_ERTS_VER=$(extract_version erts VSN)

	emake -j1 INSTALL_PREFIX="${D}" install || die "install failed"
	dodoc AUTHORS README

	dosym "${ERL_LIBDIR}/bin/erl" /usr/bin/erl
	dosym "${ERL_LIBDIR}/bin/erlc" /usr/bin/erlc
	dosym "${ERL_LIBDIR}/bin/ear" /usr/bin/ear
	dosym "${ERL_LIBDIR}/bin/escript" /usr/bin/escript
	dosym \
		"${ERL_LIBDIR}/lib/erl_interface-${ERL_INTERFACE_VER}/bin/erl_call" \
		/usr/bin/erl_call
	dosym "${ERL_LIBDIR}/erts-${ERL_ERTS_VER}/bin/beam" /usr/bin/beam

	## Remove ${ED} from the following files
	dosed "${ERL_LIBDIR}/bin/erl"
	dosed "${ERL_LIBDIR}/bin/start"
	grep -rle "${ED}" "${ED}/${ERL_LIBDIR}/erts-${ERL_ERTS_VER}" | xargs sed -i -e "s:${ED}::g"

	## Clean up the no longer needed files
	rm "${ED}/${ERL_LIBDIR}/Install"

	if use doc ; then
		for i in "${WORKDIR}"/man/man* ; do
			dodir "${ERL_LIBDIR}/${i##${WORKDIR}}"
		done
		for file in "${WORKDIR}"/man/man*/*.[1-9]; do
			# Man page processing tools expect a capitalized "SEE ALSO" section
			# header, has been reported upstream, should be fixed in R12
			sed -i -e 's,\.SH See Also,\.SH SEE ALSO,g' ${file}
			# doman sucks so we can't use it
			cp ${file} "${ED}/${ERL_LIBDIR}"/man/man${file##*.}/
		done
		# extend MANPATH, so the normal man command can find it
		# see bug 189639
		dodir /etc/env.d/
		echo "MANPATH=\"${EPREFIX}${ERL_LIBDIR}/man\"" > "${ED}/etc/env.d/90erlang"
		dohtml -A README,erl,hrl,c,h,kwc,info -r \
			"${WORKDIR}"/doc "${WORKDIR}"/lib "${WORKDIR}"/erts-*
	fi

	if use emacs ; then
		pushd "${S}"
		elisp-install erlang lib/tools/emacs/*.{el,elc}
		sed -e "s:/usr/share:${EPREFIX}/usr/share:g" \
			"${FILESDIR}"/${SITEFILE} > "${T}"/${SITEFILE}
		elisp-site-file-install "${T}"/${SITEFILE}
		popd
	fi

	# prepare erl for SMP, fixes bug #188112
	use smp && sed -i -e 's:\(exec.*erlexec\):\1 -smp:' \
		"${ED}/${ERL_LIBDIR}/bin/erl"
}

pkg_postinst() {
	use emacs && elisp-site-regen
	elog
	elog "If you need a symlink to one of erlang's binaries,"
	elog "please open a bug and tell the maintainers."
	elog
	elog "Gentoo's versioning scheme differs from the author's, so please refer to this version as R11B-5"
	elog
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
