# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mono.eclass,v 1.10 2008/12/26 00:37:47 loki_val Exp $

# @ECLASS: mono.eclass
# @MAINTAINER:
# dotnet@gentoo.org
# @BLURB: common settings and functions for mono and dotnet related
# packages
# @DESCRIPTION:
# The mono eclass contains common environment settings that are useful for
# dotnet packages.  Currently, it provides no functions, just exports
# MONO_SHARED_DIR and sets LC_ALL in order to prevent errors during compilation
# of dotnet packages.

# >=mono-0.92 versions using mcs -pkg:foo-sharp require shared memory, so we set the
# shared dir to ${T} so that ${T}/.wapi can be used during the install process.
export MONO_SHARED_DIR="${T}"

# Building mono, nant and many other dotnet packages is known to fail if LC_ALL
# variable is not set to C. To prevent this all mono related packages will be
# build with LC_ALL=C (see bugs #146424, #149817)
export LC_ALL=C

# Monodevelop-using applications need this to be set or they will try to create config
# files in the user's ~ dir.

export XDG_CONFIG_HOME="${T}"

# Fix bug 83020:
# "Access Violations Arise When Emerging Mono-Related Packages with MONO_AOT_CACHE"

unset MONO_AOT_CACHE
