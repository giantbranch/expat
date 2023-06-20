#!/bin/bash -eu

# build project
# e.g.
# ./autogen.sh
# ./configure
# make -j$(nproc) all

# build fuzzers
# e.g.
# $CXX $CXXFLAGS -std=c++11 -Iinclude \
#     /path/to/name_of_fuzzer.cc -o $OUT/name_of_fuzzer \
#     $LIB_FUZZING_ENGINE /path/to/library.a
cd $SRC/expat/

: ${LD:="${CXX}"}
: ${LDFLAGS:="${CXXFLAGS}"}  # to make sure we link with sanitizer runtime

cmake_args=(
    # Specific to Expat
    -DEXPAT_BUILD_FUZZERS=ON
    -DEXPAT_OSSFUZZ_BUILD=ON
    -DEXPAT_SHARED_LIBS=OFF

    # C compiler
    -DCMAKE_C_COMPILER="${CC}"
    -DCMAKE_C_FLAGS="${CFLAGS}"

    # C++ compiler
    -DCMAKE_CXX_COMPILER="${CXX}"
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}"

    # Linker
    -DCMAKE_LINKER="${LD}"
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}"
    -DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS}"
    -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}"
)

mkdir -p build
cd build
cmake ../expat "${cmake_args[@]}"
make -j$(nproc)

for fuzzer in fuzz/*;
do
  cp $fuzzer $OUT
done

#cd $SRC/expat/expat

#./buildconf.sh

#./configure

#make clean
#make -j$(nproc) all

#$CC $CFLAGS -Ilib/ \
#	    fuzz/xml_parse_fuzzer.c -o $OUT/xml_parse_fuzzer \
#	        $LIB_FUZZING_ENGINE lib/.libs/libexpat.a

# Optional: Copy dictionaries and options files.
#cp $SRC/*.dict $SRC/*.options $OUT/
