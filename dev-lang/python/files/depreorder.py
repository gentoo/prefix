#!/usr/bin/python

# tries to reorder the deps of a given list of packages so they
# are merged in order - liquidx@g.o (09 Oct 03)

import portage
import sys, string

fakedbapi = portage.fakedbapi()
varapi = portage.db["/"]["vartree"].dbapi

pkgs_to_reorder = sys.argv[1:]
pkgs_ordered = []
# key = catpkgver
# value = ( added, dependencies, slot )
DEP_ADDED = 0
DEP_DEPLIST = 1
DEP_SLOT = 2
dep_cache = {}

    
# very simply, we extract the dependencies for each package
for pkg in pkgs_to_reorder:
    try:
        deps, slot = varapi.aux_get(pkg, ["DEPEND", "SLOT"])
    except ValueError:
        sys.stderr.write("Error getting dependency information off " + pkg + "\n")
        continue
    try:
        realdeps = portage.dep_check(deps, fakedbapi)
    except TypeError:
        # we're probably running >=portage-2.0.50
        pkgsettings = portage.config(clone=portage.settings)        
        realdeps = portage.dep_check(deps, fakedbapi, pkgsettings)

    vardeps = []
    # match() finds the versions of all those that are installed
    for dep in realdeps[1]:
        vardeps = vardeps + varapi.match(dep)
    dep_cache[pkg] = ( 0, vardeps, slot )

# then we just naively append to a sorted list of deps using this rule.
# if a dependency is going to be merged, we add it to the list like
# with the dep then the pkg itself.
# eg: dev-python/pyqt deps on dev-python/sip, so we the list will look like
# [dev-python/sip, dev-python/pyqt]
for pkg, depinfo in dep_cache.items():
    dep_to_add = []
    for dep in depinfo[DEP_DEPLIST]:
        if dep in pkgs_to_reorder:
            dep_to_add.append(dep)
            
    pkgs_ordered += dep_to_add + [pkg]
    
# now, because the packages may have nested or multple dependencies, we
# then move thru the list from first to last and remove all duplicates.
# that way we know for sure that a package isn't merged twice or a dep
# comes before the package that depends on it.
pkgs_final_order = []
for pkg in pkgs_ordered:
    if pkg not in pkgs_final_order:
        pkgs_final_order += [pkg]
	    
print string.join(pkgs_final_order, "\n")
#print portage.dep_expand("=dev-python/sip-3.8", portage.portdb)
#print portage.dep_check("X? ( >=dev-python/sip-3.8 )", fakedbapi)
