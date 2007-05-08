# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/java-vm-2.eclass,v 1.17 2007/05/07 15:51:29 betelgeuse Exp $

# -----------------------------------------------------------------------------
# @eclass-begin
# @eclass-shortdesc Java Virtual Machine eclass
# @eclass-maintainer java@gentoo.org
#
# This eclass provides functionality which assists with installing
# virtual machines, and ensures that they are recognized by java-config.
#
# -----------------------------------------------------------------------------

inherit eutils fdo-mime

DEPEND="
	=dev-java/java-config-2.0*
	>=sys-apps/portage-2.1"
RDEPEND="
	=dev-java/java-config-2.0*
	=dev-java/java-config-1.3*"

export WANT_JAVA_CONFIG=2

JAVA_VM_CONFIG_DIR="/usr/share/java-config-2/vm"
JAVA_VM_DIR="/usr/lib/jvm"

EXPORT_FUNCTIONS pkg_setup pkg_postinst pkg_prerm pkg_postrm

java-vm-2_pkg_setup() {
	if [[ "${SLOT}" != "0" ]]; then
		VMHANDLE=${PN}-${SLOT}
	else
		VMHANDLE=${PN}
	fi
}

java-vm-2_pkg_postinst() {
	# Set the generation-2 system VM, if it isn't set
	if [[ -z "$(java-config-2 -f)" ]]; then
		java_set_default_vm_
	fi

	# support both variables for now
	if [[ ${JAVA_SUPPORTS_GENERATION_1} == 'true' && ${JAVA_VM_NO_GENERATION1} != 'true' ]]; then
		local systemvm1="$(java-config-1 -f 2>/dev/null)"
		# no generation-1 system-vm was previously set
		if [[ -z "${systemvm1}" ]]; then
			# if 20java exists, must be using old VM
			if [[ -f /etc/env.d/20java ]]; then
				ewarn "The current generation-1 system-vm is using an out-of-date VM,"
				ewarn "as in, it hasn't been updated for use with the new Java sytem."
			# othewise, it must not have been set before
			else
				ewarn "No generation-1 system-vm previously set."
			fi
			ewarn "Setting generation-1 system-vm to ${VMHANDLE}"
			java-config-1 --set-system-vm=${P} 2>/dev/null
		# dirty check to see if we are upgrading current generation-1 system vm
		elif [[ "${systemvm1}" = ${VMHANDLE}* ]]; then
			einfo "Emerging the current generation-1 system-vm..."
			einfo "Updating its config files."
			java-config-1 --set-system-vm=${P} 2>/dev/null
		# dirty check to see if current system vm is a jre - replace it with
		elif [[ "${systemvm1}" = *jre* ]]; then
			ewarn "Current generation-1 system-vm is a JRE"
			ewarn "For the new and old Java systems to coexist,"
			ewarn "the generation-1 system-vm must be a JDK."
			ewarn "Setting generation-1 system-vm to ${VMHANDLE}"
			java-config-1 --set-system-vm=${P} 2>/dev/null
		fi
		# else... some other VM is being updated, so we don't have to worry
	else
		einfo "JREs and 1.5+ JDKs are not supported for use with generation-1."
		einfo "This is because generation-1 is only for use for building packages."
		einfo "Only generation-2 should be used by end-users,"
		einfo "where all JREs and JDKs will be available"
	fi

	echo

	java-vm_check-nsplugin
	java_mozilla_clean_
	fdo-mime_desktop_database_update
}

java-vm_check-nsplugin() {
	local libdir
	if [[ ${VMHANDLE} =~ emul-linux-x86 ]]; then
		libdir=lib32
	else
		libdir=lib
	fi
	# Install a default nsplugin if we don't already have one
	if has nsplugin ${IUSE} && use nsplugin; then
		if [[ ! -f /usr/${libdir}/nsbrowser/plugins/javaplugin.so ]]; then
			einfo "No system nsplugin currently set."
			java-vm_set-nsplugin
		else
			einfo "System nsplugin is already set, not changing it."
		fi
		einfo "You can change nsplugin with eselect java-nsplugin."
	fi
}

java-vm_set-nsplugin() {
	local extra_args
	if use amd64; then
		if [[ ${VMHANDLE} =~ emul-linux-x86 ]]; then
			extra_args="32bit"
		else
			extra_args="64bit"
		fi
		einfo "Setting ${extra_args} nsplugin to ${VMHANDLE}"
	else
		einfo "Setting nsplugin to ${VMHANDLE}..."
	fi
	eselect java-nsplugin set ${extra_args} ${VMHANDLE}
}

java-vm-2_pkg_prerm() {
	if [[ "$(java-config -f 2>/dev/null)" == "${VMHANDLE}" ]]; then
		ewarn "It appears you are removing your system-vm!"
		ewarn "Please run java-config -L to list available VMs,"
		ewarn "then use java-config -S to set a new system-vm!"
	fi
}

java-vm-2_pkg_postrm() {
	fdo-mime_desktop_database_update
}

java_set_default_vm_() {
	java-config-2 --set-system-vm="${VMHANDLE}"

	einfo " ${P} set as the default system-vm."
}

get_system_arch() {
	local sarch
	sarch=$(echo ${ARCH} | sed -e s/[i]*.86/i386/ -e s/x86_64/amd64/ -e s/sun4u/sparc/ -e s/sparc64/sparc/ -e s/arm.*/arm/ -e s/sa110/arm/)
	if [ -z "${sarch}" ]; then
		sarch=$(uname -m | sed -e s/[i]*.86/i386/ -e s/x86_64/amd64/ -e s/sun4u/sparc/ -e s/sparc64/sparc/ -e s/arm.*/arm/ -e s/sa110/arm/)
	fi
	echo ${sarch}
}

# TODO rename to something more evident, like install_env_file
set_java_env() {
	local platform="$(get_system_arch)"
	local env_file="${ED}${JAVA_VM_CONFIG_DIR}/${VMHANDLE}"
	local old_env_file="${ED}/etc/env.d/java/20${P}"
	local source_env_file="${FILESDIR}/${VMHANDLE}.env"

	if [[ ! -f ${source_env_file} ]]; then
		die "Unable to find the env file: ${source_env_file}"
	fi

	dodir ${JAVA_VM_CONFIG_DIR}
	sed \
		-e "s/@P@/${P}/g" \
		-e "s/@PN@/${PN}/g" \
		-e "s/@PV@/${PV}/g" \
		-e "s/@PF@/${PF}/g" \
		-e "s/@PLATFORM@/${platform}/g" \
		-e "/^LDPATH=.*lib\\/\\\"/s|\"\\(.*\\)\"|\"\\1${platform}/:\\1${platform}/server/\"|" \
		< ${source_env_file} \
		> ${env_file} || die "sed failed"

	echo "VMHANDLE=\"${VMHANDLE}\"" >> ${env_file}

	# generation-1 compatibility
	# respect both variables for now...
	if [[ ${JAVA_SUPPORTS_GENERATION_1} == 'true' && ${JAVA_VM_NO_GENERATION1} != 'true' ]]; then
		einfo "Enabling generation-1 compatibility..."
		dodir /etc/env.d/java # generation-1 compatibility
		# We need to strip some things out of the new style env,
		# because these end up going in the env
		sed -e 's/.*CLASSPATH.*//' \
			-e 's/.*PROVIDES.*//' \
			${env_file} \
			> ${old_env_file} || die "failed to create generation-1 env file"
	else
		ewarn "Disabling generation-1 compatibility..."
	fi

	[[ -n ${JAVA_PROVIDE} ]] && echo "PROVIDES=\"${JAVA_PROVIDE}\"" >> ${env_file}

	local java_home=$(source ${env_file}; echo ${JAVA_HOME})
	[[ -z ${java_home} ]] && die "No JAVA_HOME defined in ${env_file}"

	# Make the symlink
	dosym ${java_home} ${JAVA_VM_DIR}/${VMHANDLE} \
		|| die "Failed to make VM symlink at ${JAVA_VM_DIR}/${VMHANDLE}"
}


java_get_plugin_dir_() {
	echo /usr/$(get_libdir)/nsbrowser/plugins
}

install_mozilla_plugin() {
	local plugin=${1}

	if [ ! -f "${ED}/${plugin}" ] ; then
		die "Cannot find mozilla plugin at ${ED}/${plugin}"
	fi

	local plugin_dir=/usr/share/java-config-2/nsplugin
	dodir ${plugin_dir}
	dosym ${plugin} ${plugin_dir}/${VMHANDLE}-javaplugin.so
}

java_mozilla_clean_() {
	# Because previously some ebuilds installed symlinks outside of pkg_install
	# and are left behind, which forces you to manualy remove them to select the
	# jdk/jre you want to use for java
	local plugin_dir=$(java_get_plugin_dir_)
	for file in ${plugin_dir}/javaplugin_*; do
		rm -f ${file}
	done
	for file in ${plugin_dir}/libjavaplugin*; do
		rm -f ${file}
	done
}

# ------------------------------------------------------------------------------
# @eclass-end
# ------------------------------------------------------------------------------
