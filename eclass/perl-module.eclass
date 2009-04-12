# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/perl-module.eclass,v 1.116 2009/03/29 17:32:31 tove Exp $
#
# Author: Seemant Kulleen <seemant@gentoo.org>

# @ECLASS: perl-module.eclass
# @MAINTAINER:
# perl@gentoo.org
# @BLURB: eclass for perl modules
# @DESCRIPTION:
# The perl-module eclass is designed to allow easier installation of perl
# modules, and their incorporation into the Gentoo Linux system.

inherit eutils base

case "${EAPI:-0}" in
	0|1)
		EXPORT_FUNCTIONS pkg_setup pkg_preinst pkg_postinst pkg_prerm pkg_postrm src_compile src_install src_test src_unpack
		;;
	2)
		EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_test src_install

		case "${GENTOO_DEPEND_ON_PERL:-yes}" in
			yes)
				DEPEND="dev-lang/perl[-build]"
				RDEPEND="${DEPEND}"
				;;
		esac
		;;
esac

DESCRIPTION="Based on the $ECLASS eclass"

LICENSE="${LICENSE:-|| ( Artistic GPL-2 )}"

[[ -z "${SRC_URI}" && -z "${MODULE_A}" ]] && MODULE_A="${MY_P:-${P}}.tar.gz"
[[ -z "${SRC_URI}" && -n "${MODULE_AUTHOR}" ]] && \
	SRC_URI="mirror://cpan/authors/id/${MODULE_AUTHOR:0:1}/${MODULE_AUTHOR:0:2}/${MODULE_AUTHOR}/${MODULE_SECTION}/${MODULE_A}"
[[ -z "${HOMEPAGE}" ]] && \
	HOMEPAGE="http://search.cpan.org/dist/${MY_PN:-${PN}}"

SRC_PREP="no"
SRC_TEST="skip"
PREFER_BUILDPL="yes"

PERL_VERSION=""
SITE_ARCH=""
SITE_LIB=""
ARCH_LIB=""
VENDOR_ARCH=""
VENDOR_LIB=""

pm_echovar=""
perlinfo_done=false

perl-module_src_unpack() {
	base_src_unpack unpack
	has "${EAPI:-0}" 0 1 && perl-module_src_prepare
}

perl-module_src_prepare() {
	if [[ -n ${PATCHES} ]] ; then
		base_src_unpack autopatch
	fi
	esvn_clean
}

perl-module_src_configure() {
	perl-module_src_prep
}

perl-module_src_prep() {
	[[ "${SRC_PREP}" = "yes" ]] && return 0
	SRC_PREP="yes"

	${perlinfo_done} || perlinfo

	export PERL_MM_USE_DEFAULT=1
	# Disable ExtUtils::AutoInstall from prompting
	export PERL_EXTUTILS_AUTOINSTALL="--skipdeps"

	if [[ "${PREFER_BUILDPL}" == "yes" && -f Build.PL ]] ; then
		einfo "Using Module::Build"
		perl Build.PL \
			--installdirs=vendor \
			--libdoc= \
			--destdir="${D}" \
			--create_packlist=0 \
			${myconf} \
			<<< "${pm_echovar}" \
				|| die "Unable to build! (are you using USE=\"build\"?)"
	elif [[ -f Makefile.PL ]] ; then
		einfo "Using ExtUtils::MakeMaker"
		perl Makefile.PL \
			PREFIX="${EPREFIX}"/usr \
			INSTALLDIRS=vendor \
			INSTALLMAN3DIR='none' \
			DESTDIR="${D}" \
			${myconf} \
			<<< "${pm_echovar}" \
				|| die "Unable to build! (are you using USE=\"build\"?)"
	fi
	if [[ ! -f Build.PL && ! -f Makefile.PL ]] ; then
		einfo "No Make or Build file detected..."
		return
	fi
}

perl-module_src_compile() {
	${perlinfo_done} || perlinfo

	has "${EAPI:-0}" 0 1 && perl-module_src_prep

	if [[ -f Build ]] ; then
		./Build build \
			|| die "compilation failed"
	elif [[ -f Makefile ]] ; then
		emake \
			OTHERLDFLAGS="${LDFLAGS}" \
			${mymake} \
				|| die "compilation failed"
#			OPTIMIZE="${CFLAGS}" \
	fi
}

perl-module_src_test() {
	if [[ "${SRC_TEST}" == "do" ]] ; then
		${perlinfo_done} || perlinfo
		if [[ -f Build ]] ; then
			./Build test || die "test failed"
		elif [[ -f Makefile ]] ; then
			emake test || die "test failed"
		fi
	fi
}

perl-module_src_install() {
	local f
	${perlinfo_done} || perlinfo

	if [[ -z ${mytargets} ]] ; then
		case "${CATEGORY}" in
			dev-perl|perl-core) mytargets="pure_install" ;;
			*)                  mytargets="install" ;;
		esac
	fi

	if [[ -f Build ]] ; then
		./Build ${mytargets} \
			|| die "./Build ${mytargets} failed"
	elif [[ -f Makefile ]] ; then
		emake ${myinst} ${mytargets} \
			|| die "emake ${myinst} ${mytargets} failed"
	fi

	if [[ -d "${ED}"/usr/share/man ]] ; then
#		einfo "Cleaning out stray man files"
		find "${ED}"/usr/share/man -type f -name "*.3pm" -delete
		find "${ED}"/usr/share/man -depth -type d -empty -delete
	fi

	fixlocalpod

	for f in Change* CHANGES README* ${mydoc}; do
		[[ -s "${f}" ]] && dodoc ${f}
	done

	if [[ -d "${D}/${VENDOR_LIB}" ]] ; then
		find "${D}/${VENDOR_LIB}" -type f -a \( -name .packlist \
			-o \( -name '*.bs' -a -empty \) \) -delete
		find "${D}/${VENDOR_LIB}" -depth -mindepth 1 -type d -empty -delete
	fi

	find "${ED}" -type f -not -name '*.so' -print0 | while read -rd '' f ; do
		if file "${f}" | grep -q -i " text" ; then
if grep -q "${D}" "${f}" ; then ewarn "QA: File contains a temporary path ${f}" ;fi
			sed -i -e "s:${D}:/:g" "${f}"
		fi
	done
}

perl-module_pkg_setup() {
	${perlinfo_done} || perlinfo
}

perl-module_pkg_preinst() {
	${perlinfo_done} || perlinfo
}

perl-module_pkg_postinst() { : ; }
#	einfo "Man pages are not installed for most modules now."
#	einfo "Please use perldoc instead."
#}

perl-module_pkg_prerm() { : ; }

perl-module_pkg_postrm() { : ; }

perlinfo() {
	perlinfo_done=true

	local f version install{site{arch,lib},archlib,vendor{arch,lib}}
	for f in version install{site{arch,lib},archlib,vendor{arch,lib}} ; do
		eval "$(perl -V:${f} )"
	done
	PERL_VERSION=${version}
	SITE_ARCH=${installsitearch}
	SITE_LIB=${installsitelib}
	ARCH_LIB=${installarchlib}
	VENDOR_LIB=${installvendorlib}
	VENDOR_ARCH=${installvendorarch}
}

fixlocalpod() {
	find "${ED}" -type f -name perllocal.pod -delete
	find "${ED}" -depth -mindepth 1 -type d -empty -delete
}
