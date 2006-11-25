# for as long as our tree isn't sane yet, prevent from having files
# installed into the live filesystem for non-sandbox people
export EDEST=${D}/fix/your/package/it/uses/EDEST

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

LDFLAGS="${LDFLAGS} ${OLDLDFLAGS/${LDFLAGS}/}"
# We need to get rid of superfluous spaces, as otherwise configure in
# large projects will bail out that it has changed while passing it over
export LDFLAGS=$(echo ${LDFLAGS} | sed -e "s/  +/ /g" -e "s/(^ +| +$)//g")
