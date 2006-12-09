# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/enlightenment.eclass,v 1.69 2006/12/07 17:23:49 uberlord Exp $
#
# Author: vapier@gentoo.org

inherit eutils libtool

# ECVS_STATE's:
#	release      [default]
#		KEYWORDS arch
#		SRC_URI  $P.tar.gz
#		S        $WORKDIR/$P
#
#	snap         $PV has .200##### datestamp or .### counter
#		KEYWORDS ~arch
#		SRC_URI  $P.tar.bz2
#		S        $WORKDIR/$P
#
#	live         $PV has a 9999 marker
#		KEYWORDS -*
#		SRC_URI  `cvs up`
#		S        $WORKDIR/$ECVS_MODULE
#
# Overrides:
#	KEYWORDS    EKEY_STATE
#	SRC_URI     EURI_STATE
#	S           EURI_STATE

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_postinst

#E17_DEFAULT_CVS="cvs.sourceforge.net:/cvsroot/enlightenment"
E17_DEFAULT_CVS="anoncvs.enlightenment.org:/var/cvs/e"

ECVS_STATE="release"
if [[ ${PV/9999} != ${PV} ]] ; then
	if [[ -z ${ECVS_MODULE} ]] ; then
		ECVS_MODULE=${PN}
		if [[ ${CATEGORY/libs} != ${CATEGORY} ]] ; then
			ECVS_MODULE="e17/libs/${PN}"
		else
			ECVS_MODULE="e17/apps/${PN}"
		fi
	fi
	ECVS_SERVER=${E17_ECVS_SERVER:-${ECVS_SERVER:-${E17_DEFAULT_CVS}}}
	ECVS_STATE="live"
	WANT_AUTOTOOLS="yes"
	inherit cvs
elif [[ ${PV/.200[3-9][0-1][0-9][0-3][0-9]/} != ${PV} ]] ; then
	ECVS_STATE="snap"
elif [[ ${PV%%.[0-9][0-9][0-9]} != ${PV} ]] ; then
	ECVS_STATE="snap"
	EURI_STATE="release"
fi
if [[ ${WANT_AUTOTOOLS} == "yes" ]] ; then
	WANT_AUTOCONF=${E17_WANT_AUTOCONF:-latest}
	WANT_AUTOMAKE=${E17_WANT_AUTOMAKE:-latest}
	inherit autotools
fi

DESCRIPTION="A DR17 production"
HOMEPAGE="http://www.enlightenment.org/"
case ${EURI_STATE:-${ECVS_STATE}} in
	release) SRC_URI="http://enlightenment.freedesktop.org/files/${P}.tar.gz mirror://sourceforge/enlightenment/${P}.tar.gz";;
	snap)    SRC_URI="mirror://gentoo/${P}.tar.bz2";;
	live)    SRC_URI="";;
esac

LICENSE="BSD"
SLOT="0"
case ${EKEY_STATE:-${ECVS_STATE}} in
	release) KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd";;
	snap)    KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd";;
	live)    KEYWORDS="-*";;
esac
IUSE="nls doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND="nls? ( sys-devel/gettext )"

case ${EURI_STATE:-${ECVS_STATE}} in
	release) S=${WORKDIR}/${P};;
	snap)    S=${WORKDIR}/${PN};;
	live)    S=${WORKDIR}/${ECVS_MODULE};;
esac

enlightenment_warning_msg() {
	if [[ -n ${E17_ECVS_SERVER} ]] ; then
		einfo "Using user cvs server: ${E17_ECVS_SERVER}"
	fi
	if [[ ${ECVS_STATE} == "snap" ]] ; then
		ewarn "Please do not contact the E team about bugs in Gentoo."
		ewarn "Only contact vapier@gentoo.org via e-mail or bugzilla."
		ewarn "Remember, this stuff is CVS only code so dont cry when"
		ewarn "I break you :)."
	elif [[ ${ECVS_STATE} == "live" ]] ; then
		eerror "This is a LIVE CVS ebuild."
		eerror "That means there are NO promises it will work."
		eerror "If it fails to build, FIX THE CODE YOURSELF"
		eerror "before reporting any issues."
	fi
}

enlightenment_die() {
	enlightenment_warning_msg
	die "$@"$'\n'"!!! SEND BUG REPORTS TO vapier@gentoo.org NOT THE E TEAM"
}

enlightenment_pkg_setup() {
	enlightenment_warning_msg
}

# the stupid gettextize script prevents non-interactive mode, so we hax it
gettext_modify() {
	use nls || return 0
	cp $(which gettextize) "${T}"/ || die "could not copy gettextize"
	sed -i \
		-e 's:read dummy < /dev/tty::' \
		"${T}"/gettextize
}

enlightenment_src_unpack() {
	if [[ ${ECVS_STATE} == "live" ]] ; then
		cvs_src_unpack
	else
		unpack ${A}
	fi
	gettext_modify
	[[ -s gendoc ]] && chmod a+rx gendoc
}

enlightenment_src_compile() {
	# gstreamer sucks, work around it doing stupid stuff
	export GST_REGISTRY="${S}/registry.xml"

	if [[ ! -e configure ]] ; then
		env \
			PATH="${T}:${PATH}" \
			NOCONFIGURE=yes \
			USER=blah \
			./autogen.sh \
			|| enlightenment_die "autogen failed"
		# symlinked files will cause sandbox violation
		local x
		for x in config.{guess,sub} ; do
			[[ ! -L ${x} ]] && continue
			rm -f ${x}
			touch ${x}
		done
	elif [[ ${WANT_AUTOTOOLS} == "yes" ]] ; then
		eautoreconf
	fi
	epunt_cxx
	elibtoolize
	econf ${MY_ECONF} || enlightenment_die "econf failed"
	emake || enlightenment_die "emake failed"
	use doc && [[ -x ./gendoc ]] && { ./gendoc || enlightenment_die "gendoc failed" ; }
}

enlightenment_src_install() {
	make install DESTDIR="${D}" || enlightenment_die
	find "${D}" -name CVS -type d -exec rm -rf '{}' \; 2>/dev/null
	dodoc AUTHORS ChangeLog NEWS README TODO ${EDOCS}
	use doc && [[ -d doc ]] && dohtml -r doc/*
}

enlightenment_pkg_postinst() {
	enlightenment_warning_msg
}
