# for as long as our tree isn't sane yet, prevent from having files
# installed into the live filesystem for non-sandbox people
export EDEST=${D}/fix/your/EDEST

# unfortunately the two below do not work (i.e. they don't result in the
# same as setting -L and -R in the LDFLAGS)
#export LD_LIBRARY_PATH="${EPREFIX}/lib:${EPREFIX}/usr/lib"
#export LD_RUN_PATH="${EPREFIX}/lib:${EPREFIX}/usr/lib"

# The linker in a prefixed system should look first in the prefix
# directories (search path), then the (foreign) system directories
# Because the Darwin linker complains when a directory does not exist,
# we only add them if we can find them
OLDLDFLAGS=${LDFLAGS}
LDFLAGS=""
for dir in lib64 lib usr/lib64 usr/lib;
do
	dir=${EPREFIX}/${dir}
	# note this is Solaris linker specific, but GNU supports it (make
	# sure ${dir} is a directory!)
	[[ -d ${dir} ]] && \
		LDFLAGS="${LDFLAGS} -L${dir} -Wl,-R${dir}"
done

export LDFLAGS="${LDFLAGS} ${OLDLDFLAGS/${LDFLAGS}/}"

# The compiler in a prefixed system should look in the prefix header
# dirs, like the linker does
CPPFLAGS="-I${EPREFIX}/usr/include ${CPPFLAGS/-I${EPREFIX}\/usr\/include/}"
# configure can die if it detects a CPPFLAGS "change" due to suddenly
# noticing trailing space(s)
export CPPFLAGS=${CPPFLAGS%% }
