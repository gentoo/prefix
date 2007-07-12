# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/nvidia-driver.eclass,v 1.2 2007/07/05 21:01:18 cardoe Exp $

#
# Original Author: Doug Goldstein <cardoe@gentoo.org>
# Purpose: Provide useful messages for nvidia-drivers based on currently
# installed Nvidia card
#

DEPEND="sys-apps/pciutils"

# the data below is derived from
# http://us.download.nvidia.com/XFree86/Linux-x86_64/100.14.11/README/appendix-a.html

drv_96xx="0110 0111 0112 0113 0170 0171 0172 0173 0174 0175 0176 0177 0178 \
0179 017a 017c 017d 0181 0182 0183 0185 0188 018a 018b 018c 01a0 01f0 0200 \
0201 0202 0203 0250 0251 0253 0258 0259 025b 0280 0281 0282 0286 0288 0289 \
028c"

drv_71xx="0020 0028 0029 002c 002d 00a0 0100 0101 0103 0150 0151 0152 0153"

mask_96xx=">=x11-drivers/nvidia-drivers-1.0.9700"
mask_71xx=">=x11-drivers/nvidia-drivers-1.0.7200"

# Retrieve the PCI device ID for each Nvidia video card you have
nvidia-driver-get-card() {
	local NVIDIA_CARD="$(/usr/sbin/lspci -d 10de: -n | \
	awk '/ 0300: /{print $3}' | cut -d: -f2 | tr '\n' ' ')"

	if [ -n "$NVIDIA_CARD" ]; then
		echo "$NVIDIA_CARD";
	else
		echo "0000";
	fi
}

nvidia-driver-get-mask() {
	local NVIDIA_CARDS="$(nvidia-driver-get-card)"
	for card in $NVIDIA_CARDS; do
		for drv in $drv_96xx; do
			if [ "x$card" = "x$drv" ]; then
				echo "$mask_96xx";
				return 0;
			fi
		done

		for drv in $drv_71xx; do
			if [ "x$card" = "x$drv" ]; then
				echo "$mask_71xx";
				return 0;
			fi
		done

	done

	echo "";
	return 1;
}

nvidia-driver-check-warning() {
	local NVIDIA_MASK="$(nvidia-driver-get-mask)"
	if [ -n "$NVIDIA_MASK" ]; then
		ewarn "***** WARNING *****"
		ewarn 
		ewarn "You are currently installing a version of nvidia-drivers that is"
		ewarn "known not to work with a video card you have installed on your"
		ewarn "system. If this is intentional, please ignore this. If it is not"
		ewarn "please perform the following steps:"
		ewarn
		ewarn "Add the following mask entry to /etc/portage/package.mask by"
		if [ -d "${ROOT}/etc/portage/package.mask" ]; then
			ewarn "echo \"$NVIDIA_MASK\" > /etc/portage/package.mask/nvidia-drivers"
		else
			ewarn "echo \"$NVIDIA_MASK\" >> /etc/portage/package.mask"
		fi
		ewarn
		ewarn "Failure to perform the steps above could result in a non-working"
		ewarn "X setup."
		ewarn
		ewarn "For more information please read:"
		ewarn "http://us.download.nvidia.com/XFree86/Linux-x86_64/100.14.11/README/appendix-a.html"
		ebeep 5
	fi
}


