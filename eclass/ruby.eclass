# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/ruby.eclass,v 1.56 2007/01/06 16:00:22 flameeyes Exp $
#
# Author: Mamoru KOMACHI <usata@gentoo.org>
#
# The ruby eclass is designed to allow easier installation of ruby
# softwares, and their incorporation into the Gentoo Linux system.

# src_unpack, src_compile and src_install call a set of functions to emerge
# ruby with SLOT support; econf, emake and einstall is a wrapper for ruby
# to automate configuration, make and install process (they override default
# econf, emake and einstall defined by ebuild.sh respectively).

# Functions:
# src_unpack	Unpacks source archive(s) and apply patches if any.
# src_compile	Invokes econf and emake.
# src_install	Runs einstall and erubydoc.
# econf		Detects setup.rb, install.rb, extconf.rb and configure,
#		and then runs the configure script.
# emake		Runs make if any Makefile exists.
# einstall	Calls install script or Makefile. If both not present,
#		installs programs under sitedir.
# erubydoc	Finds any documents and puts them in the right place.
#		erubydoc needs more sophistication to handle all types of
#		appropriate documents.

# Variables:
# USE_RUBY	Space delimited list of supported ruby.
#		Set it to "any" if it installs only version independent files.
#		If your ebuild supports both ruby 1.6 and 1.8 but has version
#		depenedent files such as libraries, set it to something like
#		"ruby16 ruby18". Possible values are "any ruby16 ruby18 ruby19"
# RUBY_ECONF	You can pass extra arguments to econf by defining this
#		variable. Note that you cannot specify them by command line
#		if you are using <sys-apps/portage-2.0.49-r17.
# PATCHES	Space delimited list of patch files.

inherit eutils toolchain-funcs

EXPORT_FUNCTIONS src_unpack src_compile src_install

HOMEPAGE="http://raa.ruby-lang.org/list.rhtml?name=${PN}"
SRC_URI="mirror://gentoo/${P}.tar.gz"

IUSE="examples"

SLOT="0"
LICENSE="Ruby"

# If you specify RUBY_OPTIONAL you also need to take care of ruby useflag and dependency.
if [[ ${RUBY_OPTIONAL} != "yes" ]]; then
	DEPEND="virtual/ruby"
fi

[[ -z "${RUBY}" ]] && export RUBY=${EPREFIX}/usr/bin/ruby

ruby_src_unpack() {

	unpack ${A}
	cd ${S}
	# apply bulk patches
	if [[ -n "${PATCHES}" ]] ; then
		for p in ${PATCHES} ; do
			epatch $p
		done
	fi
}

ruby_econf() {

	RUBY_ECONF="${RUBY_ECONF} ${EXTRA_ECONF}"
	if [ -f configure ] ; then
		./configure \
			--prefix="${EPREFIX}"/usr \
			--host=${CHOST} \
			--mandir="${EPREFIX}"/usr/share/man \
			--infodir="${EPREFIX}"/usr/share/info \
			--datadir="${EPREFIX}"/usr/share \
			--sysconfdir="${EPREFIX}"/etc \
			--localstatedir="${EPREFIX}"/var/lib \
			--with-ruby=${RUBY} \
			${RUBY_ECONF} \
			"$@" || die "econf failed"
	fi
	if [ -f install.rb ] ; then
		${RUBY} install.rb config --prefix="${EPREFIX}"/usr "$@" \
			${RUBY_ECONF} || die "install.rb config failed"
		${RUBY} install.rb setup "$@" \
			${RUBY_ECONF} || die "install.rb setup failed"
	fi
	if [ -f setup.rb ] ; then
		${RUBY} setup.rb config --prefix="${EPREFIX}"/usr "$@" \
			${RUBY_ECONF} || die "setup.rb config failed"
		${RUBY} setup.rb setup "$@" \
			${RUBY_ECONF} || die "setup.rb setup failed"
	fi
	if [ -f extconf.rb ] ; then
		${RUBY} extconf.rb "$@" \
			${RUBY_ECONF} || die "extconf.rb failed"
	fi
}

ruby_emake() {
	if [ -f makefiles -o -f GNUmakefile -o -f makefile -o -f Makefile ] ; then
		make CC="$(tc-getCC)" CXX="$(tc-getCXX)" DLDFLAGS="${LDFLAGS}" ${MAKEOPTS} ${EXTRA_EMAKE} "$@" || die "emake for ruby failed"
	fi
}

ruby_src_compile() {

	# You can pass configure options via RUBY_ECONF
	ruby_econf || die
	ruby_emake "$@" || die
}

doruby() {
	INSDESTTREE="$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitedir"]')" \
	INSOPTIONS="-m 0644" \
	doins "$@" || die "failed to install $@"
}

ruby_einstall() {
	local siteruby

	RUBY_ECONF="${RUBY_ECONF} ${EXTRA_ECONF}"
	if [ -f install.rb ] ; then
		${RUBY} install.rb config --prefix="${ED}"/usr "$@" \
			${RUBY_ECONF} || die "install.rb config failed"
		${RUBY} install.rb install "$@" \
			${RUBY_ECONF} || die "install.rb install failed"
	elif [ -f setup.rb ] ; then
		${RUBY} setup.rb config --prefix="${ED}"/usr "$@" \
			${RUBY_ECONF} || die "setup.rb config failed"
		${RUBY} setup.rb install "$@" \
			${RUBY_ECONF} || die "setup.rb install failed"
	elif [ -f extconf.rb -o -f Makefile ] ; then
		make DESTDIR="${D}" "$@" install || die "make install failed"
	else
		siteruby=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitedir"]')
		insinto ${siteruby}
		doins *.rb || die "doins failed"
	fi
}

erubydoc() {
	local rdbase=/usr/share/doc/${PF}/rd rdfiles=$(find . -name '*.rd*')

	einfo "running dodoc for ruby ;)"

	insinto ${rdbase}
	[ -n "${rdfiles}" ] && doins ${rdfiles}
	rmdir ${ED}${rdbase} 2>/dev/null || true
	if [ -d doc -o -d docs ] ; then
		dohtml -x html -r {doc,docs}/*
		dohtml -r {doc,docs}/html/*
	else
		dohtml -r *
	fi

	if ( use examples ); then
		for dir in sample example examples; do
			if [ -d ${dir} ] ; then
				dodir /usr/share/doc/${PF}
				cp -pPR ${dir} ${ED}/usr/share/doc/${PF} || die "cp failed"
			fi
		done
	fi

	# Pattern matching will mismatch for locales without case based
	# character sorting (from bug #129526)
	export LC_COLLATE=C
	unset LC_ALL

	for i in ChangeLog* [A-Z][A-Z]* ; do
		[ -e $i ] && dodoc $i
	done
}

ruby_src_install() {

	ruby_einstall "$@" || die

	erubydoc
}

# erubyconf, erubymake and erubyinstall are kept for compatibility
erubyconf() {
	ruby_econf "$@"
}

erubymake() {
	ruby_emake "$@"
}

erubyinstall() {
	ruby_einstall "$@"
}

# prepall adds SLOT support for ruby.eclass
prepall() {

	[[ ! -x ${EPREFIX}/usr/bin/ruby16 ]] && export USE_RUBY=${USE_RUBY/ruby16/}
	[[ ! -x ${EPREFIX}/usr/bin/ruby18 ]] && export USE_RUBY=${USE_RUBY/ruby18/}
	[[ ! -x ${EPREFIX}/usr/bin/ruby19 ]] && export USE_RUBY=${USE_RUBY/ruby19/}

	local ruby_slots=$(echo "${USE_RUBY}" | wc -w)

	if [ "$ruby_slots" -ge 2 ] ;
	then
		einfo "Now we are building the package for ${USE_RUBY}"
		for rb in ${USE_RUBY} ruby ; do
			einfo "Using $rb"
			export RUBY=${EPREFIX}/usr/bin/$rb
			ruby() { "${EPREFIX}"/usr/bin/$rb "$@" ; }
			mkdir -p ${S}
			cd ${WORKDIR}
			einfo "Unpacking for $rb"
			src_unpack || die "src_unpack failed"
			cd ${S}
			find . -name '*.[ao]' -exec rm {} \;
			einfo "Building for $rb"
			src_compile || die "src_compile failed"
			cd ${S}
			einfo "Installing for $rb"
			src_install || die "src_install failed"
		done
	elif [ "${USE_RUBY}" == "any" ] ; then
		siteruby=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitelibdir"]')
		# in case no directories found in siteruby
		local shopts=$-
		set -o noglob # so that bash doen't expand "*"

		for x in ${D}/${siteruby}/* ; do
			mv $x ${D}/${siteruby}/..
		done
		if [ -d ${D}${siteruby} ] ; then
			rmdir --ignore-fail-on-non-empty ${D}/${siteruby}
		fi

		set +noglob; set -$shopts # reset old shell opts
	fi

	prepallman
	prepallinfo
	prepallstrip
}

