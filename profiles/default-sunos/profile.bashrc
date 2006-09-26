# TODO: fix this for Solaris

export DYLD_LIBRARY_PATH="${EPREFIX}/lib:${EPREFIX}/lib64:${EPREFIX}/usr/lib:${EPREFIX}/usr/lib64"

# The linker in a prefixed system should look first in the prefix
# directories (search path), then the (foreign) system directories
# Because the Darwin linker complains when a directory does not exist,
# we only add them if we can find them
OLDLDFLAGS=${LDFLAGS}
LDFLAGS=""
for dir in lib64 lib usr/lib64 usr/lib;
do
	dir=${EPREFIX}/${dir}
	[[ -d ${dir} ]] && \
		LDFLAGS="${LDFLAGS} -L${dir}"
done

export LDFLAGS="${LDFLAGS} ${OLDLDFLAGS/${LDFLAGS}/}"

# The compiler in a prefixed system should look in the prefix header
# dirs, like the linker does
export CPPFLAGS="-I${EPREFIX}/usr/include ${CPPFLAGS/-I${EPREFIX}\/usr\/include/}"
