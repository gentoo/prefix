# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/gcc-config.git"
	inherit git-r3
else
	SRC_URI="https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/${P}.tar.xz"
	KEYWORDS="~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
fi

DESCRIPTION="Utility to manage compilers"
HOMEPAGE="https://gitweb.gentoo.org/proj/gcc-config.git/"

LICENSE="GPL-2"
SLOT="0"
IUSE="+cc-wrappers +native-symlinks"

RDEPEND=">=sys-apps/gentoo-functions-0.10"

PATCHES=(
	"${FILESDIR}"/${PN}-1.8-copy-gcc-libs-darwin.patch
	"${FILESDIR}"/${PN}-1.9-cygwin.patch
)

_emake() {
	emake \
		PV="${PVR}" \
		SUBLIBDIR="$(get_libdir)" \
		USE_CC_WRAPPERS="$(usex cc-wrappers)" \
		USE_NATIVE_LINKS="$(usex native-symlinks)" \
		TOOLCHAIN_PREFIX="${CHOST}-" \
		"$@"
}

src_compile() {
	_emake
}

src_install() {
	_emake DESTDIR="${D}" install
}

pkg_postinst() {
	# Do we have a valid multi ver setup ?
	local x
	for x in $(gcc-config -C -l 2>/dev/null | awk '$NF == "*" { print $2 }') ; do
		gcc-config ${x}
	done

	# USE flag change can add or delete files in /usr/bin worth recaching
	if [[ ! ${ROOT} && -f ${EPREFIX}/usr/share/eselect/modules/compiler-shadow.eselect ]] ; then
		eselect compiler-shadow update all
	fi

	if ! has_version "sys-devel/gcc[gcj(-)]" && [[ -x "${EROOT}"/usr/bin/gcj ]] ; then
		# Warn about obsolete /usr/bin/gcj for bug #804178
		ewarn "Obsolete GCJ wrapper found: ${EROOT}/usr/bin/gcj!"
		ewarn "Please delete this file unless you know it is needed (e.g. custom gcj install)."
		ewarn "If you have no idea what this means, please delete the file:"
		ewarn " rm ${EROOT}/usr/bin/gcj"
	fi
}
