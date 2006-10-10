# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/perl-app.eclass,v 1.9 2006/08/28 20:22:20 mcummings Exp $

#
# Author: Michael Cummings <mcummings@gentoo.org>
# Maintained by the Perl herd <perl@gentoo.org>
#
# The perl-app eclass is designed to allow easier installation of perl
# apps, ineheriting the full structure of the perl-module eclass but allowing
# man3 pages to be built. This is to work around a collision-protect bug in the
# default perl-module eclass

inherit perl-module

EXPORT_FUNCTIONS src_compile

perl-app_src_prep() {
	perlinfo

	export PERL_MM_USE_DEFAULT=1
	# Disable ExtUtils::AutoInstall from prompting
	export PERL_EXTUTILS_AUTOINSTALL="--skipdeps"


	SRC_PREP="yes"
	pwd
	if [ "${PREFER_BUILDPL}" == "yes" ] && ( [ -f Build.PL ] || [ ${PN} == "module-build" ] ); then
		einfo "Using Module::Build"
		echo "$pm_echovar" | perl Build.PL --installdirs=vendor --destdir=${D} --libdoc= || die "Unable to build! (are you using USE=\"build\"?)"
	elif [ -f Makefile.PL ] && [ ! ${PN} == "module-build" ]; then
		einfo "Using ExtUtils::MakeMaker"
		echo "$pm_echovar" | perl Makefile.PL ${myconf} INSTALLMAN3DIR='none'\
		PREFIX=/usr INSTALLDIRS=vendor DESTDIR=${D} || die "Unable to build! (are you using USE=\"build\"?)"
	fi
	if [ ! -f Build.PL ] && [ ! -f Makefile.PL ]; then
		einfo "No Make or Build file detected..."
		return
	fi
}

perl-app_src_compile() {

	perlinfo
	[ "${SRC_PREP}" != "yes" ] && perl-app_src_prep
	if [ -f Makefile ]; then
		make ${mymake} || die "compilation failed"
	elif [ -f Build ]; then
		perl Build build || die "compilation failed"
	fi

}
