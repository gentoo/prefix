# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rubygems/rubygems-1.3.3.ebuild,v 1.1 2009/05/09 08:39:37 a3li Exp $

inherit ruby

DESCRIPTION="Centralized Ruby extension management system"
HOMEPAGE="http://rubyforge.org/projects/rubygems/"
LICENSE="|| ( Ruby GPL-2 )"

# Needs to be installed first
RESTRICT="test"

# The URL depends implicitly on the version, unfortunately. Even if you
# change the filename on the end, it still downloads the same file.
SRC_URI="mirror://rubyforge/${PN}/${P}.tgz"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="doc server"
DEPEND="=dev-lang/ruby-1.8*"
RDEPEND="${DEPEND}"
PDEPEND="server? ( dev-ruby/builder )" # index_gem_repository.rb

USE_RUBY="ruby18"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.3.3-setup.patch"
	# Fixes a new "feature" that would prevent us from recognizing installed
	# gems inside the sandbox
	epatch "${FILESDIR}/${PN}-1.3.3-gentoo.patch"
}

src_compile() {
	# Allowing ruby_src_compile would be bad with the new setup.rb
	:
}

src_install() {
	# RUBYOPT=-rauto_gem without rubygems installed will cause ruby to fail, bug #158455
	export RUBYOPT="${GENTOO_RUBYOPT}"
	ewarn "RUBYOPT=${RUBYOPT}"

	# Force ebuild to use Ruby 1.8
	export RUBY="${EPREFIX}/usr/bin/ruby18"

	ver=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["ruby_version"]')

	# rubygems tries to create GEM_HOME if it doesn't exist, upsetting sandbox,
	# bug #202109. Since 1.2.0 we also need to set GEM_PATH
	# for this reason, bug #230163.
	export GEM_HOME="${ED}/usr/$(get_libdir)/ruby/gems/${ver}"
	export GEM_PATH="${GEM_HOME}/"
	keepdir /usr/$(get_libdir)/ruby/gems/$ver/{doc,gems,cache,specifications}

	myconf=""
	if ! use doc; then
		myconf="${myconf} --no-ri"
		myconf="${myconf} --no-rdoc"
	fi

	${RUBY} setup.rb $myconf --destdir="${D}" || die "setup.rb install failed"

	dodoc README || die "dodoc README failed"

	cp "${FILESDIR}/auto_gem.rb" "${D}"/$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitedir"]') || die "cp auto_gem.rb failed"
	doenvd "${FILESDIR}/10rubygems" || die "doenvd 10rubygems failed"

	if use server; then
		newinitd "${FILESDIR}/init.d-gem_server2" gem_server || die "newinitd failed"
		newconfd "${FILESDIR}/conf.d-gem_server" gem_server || die "newconfd failed"
	fi
}

pkg_postinst()
{
	SOURCE_CACHE="${EPREFIX}/usr/$(get_libdir)/ruby/gems/$ver/source_cache"
	if [[ -e "${SOURCE_CACHE}" ]]; then
		rm "${SOURCE_CACHE}"
	fi

	if [[ ! -n $(readlink "${EROOT}"usr/bin/gem) ]] ; then
		eselect ruby set ruby18
	fi

	ewarn
	ewarn "This ebuild is compatible to eselect-ruby"
	ewarn "To switch between available Ruby profiles, execute as root:"
	ewarn "\teselect ruby set ruby(18|19|...)"
	ewarn
}

pkg_postrm()
{
	ewarn "If you have uninstalled dev-ruby/rubygems, Ruby applications are unlikely"
	ewarn "to run in current shells because of missing auto_gem."
	ewarn "Please run \"unset RUBYOPT\" in your shells before using ruby"
	ewarn "or start new shells"
	ewarn
	ewarn "If you have not uninstalled dev-ruby/rubygems, please do not unset "
	ewarn "RUBYOPT"
}
