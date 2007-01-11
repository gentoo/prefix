# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/versionator.eclass,v 1.12 2007/01/10 05:49:10 antarus Exp $
#
# Original Author: Ciaran McCreesh <ciaranm@gentoo.org>
#
# This eclass provides functions which simplify manipulating $PV and similar
# variables. Most functions default to working with $PV, although other
# values can be used.
#
# Simple Example 1: $PV is 1.2.3b, we want 1_2.3b:
#     MY_PV=$(replace_version_separator 1 '_' )
#
# Simple Example 2: $PV is 1.4.5, we want 1:
#     MY_MAJORV=$(get_major_version )
#
# Full list of user usable functions provided by this eclass (see the functions
# themselves for documentation):
#     get_all_version_components          ver_str
#     get_version_components              ver_str
#     get_major_version                   ver_str
#     get_version_component_range         range     ver_str
#     get_after_major_version             ver_str
#     replace_version_separator           index     newvalue   ver_str
#     replace_all_version_separators      newvalue  ver_str
#     delete_version_separator            index ver_str
#     delete_all_version_separators       ver_str
#     get_version_component_count         ver_str
#     get_last_version_component_index    ver_str
#
# Rather than being a number, the index parameter can be a separator character
# such as '-', '.' or '_'. In this case, the first separator of this kind is
# selected.
#
# There's also:
#     version_is_at_least             want      have
# which may be buggy, so use with caution.

# Quick function to toggle the shopts required for some functions on and off
# Used because we can't set extglob in global scope anymore (QA Violation)
__versionator_shopt_toggle() {
	VERSIONATOR_RECURSION=${VERSIONATOR_RECURSION:-0}
	case "$1" in
		"on")
			if [[ $VERSIONATOR_RECURSION -lt 1 ]] ;  then
				VERSIONATOR_OLD_EXTGLOB=$(shopt -p extglob)
				shopt -s extglob
			fi
			VERSIONATOR_RECURSION=$(( $VERSIONATOR_RECURSION + 1 ))
			;;
		"off")
			VERSIONATOR_RECURSION=$(( $VERSIONATOR_RECURSION - 1 ))
			if [[ $VERSIONATOR_RECURSION -lt 1 ]] ; then
				eval $VERSIONATOR_OLD_EXTGLOB
			fi
			;;
	esac
	return 0
}

# Split up a version string into its component parts. If no parameter is
# supplied, defaults to $PV.
#     0.8.3       ->  0 . 8 . 3
#     7c          ->  7 c
#     3.0_p2      ->  3 . 0 _ p2
#     20040905    ->  20040905
#     3.0c-r1     ->  3 . 0 c - r1
get_all_version_components() {
	__versionator_shopt_toggle on
	local ver_str=${1:-${PV}} result result_idx=0
	result=( )

	# sneaky cache trick cache to avoid having to parse the same thing several
	# times.
	if [[ "${VERSIONATOR_CACHE_VER_STR}" == "${ver_str}" ]] ; then
		echo ${VERSIONATOR_CACHE_RESULT}
		__versionator_shopt_toggle off
		return
	fi
	export VERSIONATOR_CACHE_VER_STR="${ver_str}"

	while [[ -n "$ver_str" ]] ; do
		case "${ver_str:0:1}" in
			# number: parse whilst we have a number
			[[:digit:]])
				result[$result_idx]="${ver_str%%[^[:digit:]]*}"
				ver_str="${ver_str##+([[:digit:]])}"
				result_idx=$(($result_idx + 1))
				;;

			# separator: single character
			[-_.])
				result[$result_idx]="${ver_str:0:1}"
				ver_str="${ver_str:1}"
				result_idx=$(($result_idx + 1))
				;;

			# letter: grab the letters plus any following numbers
			[[:alpha:]])
				local not_match="${ver_str##+([[:alpha:]])*([[:digit:]])}"
				result[$result_idx]=${ver_str:0:$((${#ver_str} - ${#not_match}))}
				ver_str="${not_match}"
				result_idx=$(($result_idx + 1))
				;;

			# huh?
			*)
				result[$result_idx]="${ver_str:0:1}"
				ver_str="${ver_str:1}"
				result_idx=$(($result_idx + 1))
				;;
		esac
	done

	export VERSIONATOR_CACHE_RESULT="${result[@]}"
	echo ${result[@]}
	__versionator_shopt_toggle off
}

# Get the important version components, excluding '.', '-' and '_'. Defaults to
# $PV if no parameter is supplied.
#     0.8.3       ->  0 8 3
#     7c          ->  7 c
#     3.0_p2      ->  3 0 p2
#     20040905    ->  20040905
#     3.0c-r1     ->  3 0 c r1
get_version_components() {
	__versionator_shopt_toggle on
	local c="$(get_all_version_components "${1:-${PV}}")"
	c=( ${c[@]//[-._]/ } )
	echo ${c[@]}
	__versionator_shopt_toggle off
}

# Get the major version of a value. Defaults to $PV if no parameter is supplied.
#     0.8.3       ->  0
#     7c          ->  7
#     3.0_p2      ->  3
#     20040905    ->  20040905
#     3.0c-r1     ->  3
get_major_version() {
	__versionator_shopt_toggle on
	local c
	c=( $(get_all_version_components "${1:-${PV}}" ) )
	echo ${c[0]}
	__versionator_shopt_toggle off
}

# Get a particular component or range of components from the version. If no
# version parameter is supplied, defaults to $PV.
#    1      1.2.3       -> 1
#    1-2    1.2.3       -> 1.2
#    2-     1.2.3       -> 2.3
get_version_component_range() {
	__versionator_shopt_toggle on 
	local c v="${2:-${PV}}" range="${1}" range_start range_end i=-1 j=0
	c=( $(get_all_version_components ${v} ) )
	range_start="${range%-*}" ; range_start="${range_start:-1}"
	range_end="${range#*-}"   ; range_end="${range_end:-${#c[@]}}"

	while (( j < ${range_start} )) ; do
		i=$(($i + 1))
		[[ $i -gt ${#c[@]} ]] && __versionator_shopt_toggle off && return
		[[ -n "${c[${i}]//[-._]}" ]] && j=$(($j + 1))
	done

	while (( j <= ${range_end} )) ; do
		echo -n ${c[$i]}
		[[ $i -gt ${#c[@]} ]] && __versionator_shopt_toggle off && return
		[[ -n "${c[${i}]//[-._]}" ]] && j=$(($j + 1))
		i=$(($i + 1))
	done
	__versionator_shopt_toggle off
}

# Get everything after the major version and its separator (if present) of a
# value. Defaults to $PV if no parameter is supplied.
#     0.8.3       ->  8.3
#     7c          ->  c
#     3.0_p2      ->  0_p2
#     20040905    ->  (empty string)
#     3.0c-r1     ->  0c-r1
get_after_major_version() {
	__versionator_shopt_toggle on
	echo $(get_version_component_range 2- "${1:-${PV}}" )
	__versionator_shopt_toggle off
}

# Replace the $1th separator with $2 in $3 (defaults to $PV if $3 is not
# supplied). If there are fewer than $1 separators, don't change anything.
#     1 '_' 1.2.3       -> 1_2.3
#     2 '_' 1.2.3       -> 1.2_3
#     1 '_' 1b-2.3      -> 1b_2.3
# Rather than being a number, $1 can be a separator character such as '-', '.'
# or '_'. In this case, the first separator of this kind is selected.
replace_version_separator() {
	__versionator_shopt_toggle on
	local w i c found=0 v="${3:-${PV}}"
	w=${1:-1}
	c=( $(get_all_version_components ${v} ) )
	if [[ "${w//[[:digit:]]/}" == "${w}" ]] ; then
		# it's a character, not an index
		for (( i = 0 ; i < ${#c[@]} ; i = $i + 1 )) ; do
			if [[ "${c[${i}]}" == "${w}" ]] ; then
				c[${i}]="${2}"
				break
			fi
		done
	else
		for (( i = 0 ; i < ${#c[@]} ; i = $i + 1 )) ; do
			if [[ -n "${c[${i}]//[^-._]}" ]] ; then
				found=$(($found + 1))
				if [[ "$found" == "${w}" ]] ; then
					c[${i}]="${2}"
					break
				fi
			fi
		done
	fi
	c=${c[@]}
	echo ${c// }
	__versionator_shopt_toggle off
}

# Replace all version separators in $2 (defaults to $PV) with $1.
#     '_' 1b.2.3        -> 1b_2_3
replace_all_version_separators() {
	__versionator_shopt_toggle on
	local c
	c=( $(get_all_version_components "${2:-${PV}}" ) )
	c="${c[@]//[-._]/$1}"
	echo ${c// }
	__versionator_shopt_toggle off
}

# Delete the $1th separator in $2 (defaults to $PV if $2 is not supplied). If
# there are fewer than $1 separators, don't change anything.
#     1 1.2.3       -> 12.3
#     2 1.2.3       -> 1.23
#     1 1b-2.3      -> 1b2.3
# Rather than being a number, $1 can be a separator character such as '-', '.'
# or '_'. In this case, the first separator of this kind is deleted.
delete_version_separator() {
	__versionator_shopt_toggle on
	replace_version_separator "${1}" "" "${2}"
	__versionator_shopt_toggle off
}

# Delete all version separators in $1 (defaults to $PV).
#     1b.2.3        -> 1b23
delete_all_version_separators() {
	__versionator_shopt_toggle on
	replace_all_version_separators "" "${1}"
	__versionator_shopt_toggle off
}

# How many version components are there in $1 (defaults to $PV)?
#     1.0.1       ->  3
#     3.0c-r1     ->  4
#
get_version_component_count() {
	__versionator_shopt_toggle on
	local a
	a=( $(get_version_components "${1:-${PV}}" ) )
	echo ${#a[@]}
	__versionator_shopt_toggle off
}

# What is the index of the last version component in $1 (defaults to $PV)?
# Equivalent to get_version_component_count - 1.
#     1.0.1       ->  3
#     3.0c-r1     ->  4
#
get_last_version_component_index() {
	__versionator_shopt_toggle on
	echo $(( $(get_version_component_count "${1:-${PV}}" ) - 1 ))
	__versionator_shopt_toggle off
}

# Is $2 (defaults to $PVR) at least version $1? Intended for use in eclasses
# only. May not be reliable, be sure to do very careful testing before actually
# using this. Prod ciaranm if you find something it can't handle.
version_is_at_least() {
	__versionator_shopt_toggle on
	local want_s="$1" have_s="${2:-${PVR}}" r
	version_compare "${want_s}" "${have_s}"
	r=$?
	case $r in
		1|2)
			__versionator_shopt_toggle off
			return 0
			;;
		3)
			__versionator_shopt_toggle off
			return 1
			;;
		*)
			__versionator_shopt_toggle off
			die "versionator compare bug [atleast, ${want_s}, ${have_s}, ${r}]"
			;;
	esac
	__versionator_shopt_toggle off
}

# Takes two parameters (a, b) which are versions. If a is an earlier version
# than b, returns 1. If a is identical to b, return 2. If b is later than a,
# return 3. You probably want version_is_at_least rather than this function.
# May not be very reliable. Test carefully before using this.
version_compare() {
	__versionator_shopt_toggle on
	local ver_a=${1} ver_b=${2} parts_a parts_b cur_idx_a=0 cur_idx_b=0
	parts_a=( $(get_all_version_components "${ver_a}" ) )
	parts_b=( $(get_all_version_components "${ver_b}" ) )

	### compare number parts.
	local inf_loop=0
	while true ; do
		inf_loop=$(( ${inf_loop} + 1 ))
		[[ ${inf_loop} -gt 20 ]] && \
			die "versionator compare bug [numbers, ${ver_a}, ${ver_b}]"

		# grab the current number components
		local cur_tok_a=${parts_a[${cur_idx_a}]}
		local cur_tok_b=${parts_b[${cur_idx_b}]}

		# number?
		if [[ -n ${cur_tok_a} ]] && [[ -z ${cur_tok_a//[[:digit:]]} ]] ; then
			cur_idx_a=$(( ${cur_idx_a} + 1 ))
			[[ ${parts_a[${cur_idx_a}]} == "." ]] \
				&& cur_idx_a=$(( ${cur_idx_a} + 1 ))
		else
			cur_tok_a=""
		fi

		if [[ -n ${cur_tok_b} ]] && [[ -z ${cur_tok_b//[[:digit:]]} ]] ; then
			cur_idx_b=$(( ${cur_idx_b} + 1 ))
			[[ ${parts_b[${cur_idx_b}]} == "." ]] \
				&& cur_idx_b=$(( ${cur_idx_b} + 1 ))
		else
			cur_tok_b=""
		fi

		# done with number components?
		[[ -z ${cur_tok_a} ]] && [[ -z ${cur_tok_b} ]] && break

		# to avoid going into octal mode, strip any leading zeros. otherwise
		# bash will throw a hissy fit on versions like 6.3.068.
		cur_tok_a=${cur_tok_a##+(0)}
		cur_tok_b=${cur_tok_b##+(0)}

		# if a component is blank, make it zero.
		[[ -z ${cur_tok_a} ]] && cur_tok_a=0
		[[ -z ${cur_tok_b} ]] && cur_tok_b=0

		# compare
		[[ ${cur_tok_a} -lt ${cur_tok_b} ]] && __versionator_shopt_toggle off && return 1
		[[ ${cur_tok_a} -gt ${cur_tok_b} ]] && __versionator_shopt_toggle off && return 3
	done

	### number parts equal. compare letter parts.
	local letter_a=
	letter_a=${parts_a[${cur_idx_a}]}
	if [[ ${#letter_a} -eq 1 ]] && [[ -z ${letter_a/[a-z]} ]] ; then
		cur_idx_a=$(( ${cur_idx_a} + 1 ))
	else
		letter_a="@"
	fi

	local letter_b=
	letter_b=${parts_b[${cur_idx_b}]}
	if [[ ${#letter_b} -eq 1 ]] && [[ -z ${letter_b/[a-z]} ]] ; then
		cur_idx_b=$(( ${cur_idx_b} + 1 ))
	else
		letter_b="@"
	fi

	# compare
	[[ ${letter_a} < ${letter_b} ]] && __versionator_shopt_toggle off && return 1
	[[ ${letter_a} > ${letter_b} ]] && __versionator_shopt_toggle off && return 3

	### letter parts equal. compare suffixes in order.
	local suffix rule part r_lt r_gt
	for rule in "alpha=1" "beta=1" "pre=1" "rc=1" "p=3" "r=3" ; do
		suffix=${rule%%=*}
		r_lt=${rule##*=}
		[[ ${r_lt} -eq 1 ]] && r_gt=3 || r_gt=1

		local suffix_a=
		for part in ${parts_a[@]} ; do
			[[ ${part#${suffix}} != ${part} ]] && \
				[[ -z ${part##${suffix}*([[:digit:]])} ]] && \
				suffix_a=${part#${suffix}}0
		done

		local suffix_b=
		for part in ${parts_b[@]} ; do
			[[ ${part#${suffix}} != ${part} ]] && \
				[[ -z ${part##${suffix}*([[:digit:]])} ]] && \
				suffix_b=${part#${suffix}}0
		done

		[[ -z ${suffix_a} ]] && [[ -z ${suffix_b} ]] && continue

		[[ -z ${suffix_a} ]] && __versionator_shopt_toggle off && return ${r_gt}
		[[ -z ${suffix_b} ]] && __versionator_shopt_toggle off && return ${r_lt}

		# avoid octal problems
		suffix_a=${suffix_a##+(0)} ; suffix_a=${suffix_a:-0}
		suffix_b=${suffix_b##+(0)} ; suffix_b=${suffix_b:-0}

		[[ ${suffix_a} -lt ${suffix_b} ]] && __versionator_shopt_toggle off && return 1
		[[ ${suffix_a} -gt ${suffix_b} ]] && __versionator_shopt_toggle off && return 3
	done

	### no differences.
	__versionator_shopt_toggle off
	return 2
}

# Returns its parameters sorted, highest version last. We're using a quadratic
# algorithm for simplicity, so don't call it with more than a few dozen items.
# Uses version_compare, so be careful.
version_sort() {
	__versionator_shopt_toggle on
	local items= left=0
	items=( $@ )
	while [[ ${left} -lt ${#items[@]} ]] ; do
		local lowest_idx=${left}
		local idx=$(( ${lowest_idx} + 1 ))
		while [[ ${idx} -lt ${#items[@]} ]] ; do
			version_compare "${items[${lowest_idx}]}" "${items[${idx}]}"
			[[ $? -eq 3 ]] && lowest_idx=${idx}
			idx=$(( ${idx} + 1 ))
		done
		local tmp=${items[${lowest_idx}]}
		items[${lowest_idx}]=${items[${left}]}
		items[${left}]=${tmp}
		left=$(( ${left} + 1 ))
	done
	echo ${items[@]}
	__versionator_shopt_toggle off
}

__versionator__test_version_compare() {
	__versionator_shopt_toggle on
	local lt=1 eq=2 gt=3 p q

	__versionator__test_version_compare_t() {
		version_compare "${1}" "${3}"
		local r=$?
		[[ ${r} -eq ${2} ]] || echo "FAIL: ${@} (got ${r} exp ${2})"
	}

	echo "
		0             $lt 1
		1             $lt 2
		2             $gt 1
		2             $eq 2
		0             $eq 0
		10            $lt 20
		68            $eq 068
		068           $gt 67
		068           $lt 69

		1.0           $lt 2.0
		2.0           $eq 2.0
		2.0           $gt 1.0

		1.0           $gt 0.0
		0.0           $eq 0.0
		0.0           $lt 1.0

		0.1           $lt 0.2
		0.2           $eq 0.2
		0.3           $gt 0.2

		1.2           $lt 2.1
		2.1           $gt 1.2

		1.2.3         $lt 1.2.4
		1.2.4         $gt 1.2.3

		1.2.0         $eq 1.2
		1.2.1         $gt 1.2
		1.2           $lt 1.2.1

		1.2b          $eq 1.2b
		1.2b          $lt 1.2c
		1.2b          $gt 1.2a
		1.2b          $gt 1.2
		1.2           $lt 1.2a

		1.3           $gt 1.2a
		1.3           $lt 1.3a

		1.0_alpha7    $lt 1.0_beta7
		1.0_beta      $lt 1.0_pre
		1.0_pre5      $lt 1.0_rc2
		1.0_rc2       $lt 1.0

		1.0_p1        $gt 1.0
		1.0_p1-r1     $gt 1.0_p1

		1.0_alpha6-r1 $gt 1.0_alpha6
		1.0_beta6-r1  $gt 1.0_alpha6-r2

		1.0_pre1      $lt 1.0-p1

		1.0p          $gt 1.0_p1
		1.0r          $gt 1.0-r1
		1.6.15        $gt 1.6.10-r2
		1.6.10-r2     $lt 1.6.15

	" | while read a b c ; do
		[[ -z "${a}${b}${c}" ]] && continue;
		__versionator__test_version_compare_t "${a}" "${b}" "${c}"
	done


	for q in "alpha beta pre rc=${lt};${gt}" "p r=${gt};${lt}" ; do
		for p in ${q%%=*} ; do
			local c=${q##*=}
			local alt=${c%%;*} agt=${c##*;}
			__versionator__test_version_compare_t "1.0" $agt "1.0_${p}"
			__versionator__test_version_compare_t "1.0" $agt "1.0_${p}1"
			__versionator__test_version_compare_t "1.0" $agt "1.0_${p}068"

			__versionator__test_version_compare_t "2.0_${p}"    $alt "2.0"
			__versionator__test_version_compare_t "2.0_${p}1"   $alt "2.0"
			__versionator__test_version_compare_t "2.0_${p}068" $alt "2.0"

			__versionator__test_version_compare_t "1.0_${p}"  $eq "1.0_${p}"
			__versionator__test_version_compare_t "0.0_${p}"  $lt "0.0_${p}1"
			__versionator__test_version_compare_t "666_${p}3" $gt "666_${p}"

			__versionator__test_version_compare_t "1_${p}7"  $lt "1_${p}8"
			__versionator__test_version_compare_t "1_${p}7"  $eq "1_${p}7"
			__versionator__test_version_compare_t "1_${p}7"  $gt "1_${p}6"
			__versionator__test_version_compare_t "1_${p}09" $eq "1_${p}9"
		done
	done

	for p in "-r" "_p" ; do
		__versionator__test_version_compare_t "7.2${p}1" $lt "7.2${p}2"
		__versionator__test_version_compare_t "7.2${p}2" $gt "7.2${p}1"
		__versionator__test_version_compare_t "7.2${p}3" $gt "7.2${p}2"
		__versionator__test_version_compare_t "7.2${p}2" $lt "7.2${p}3"
	done
	__versionator_shopt_toggle off
}

