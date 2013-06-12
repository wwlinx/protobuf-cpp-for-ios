configure_for_platform() {
	export PLATFORM=$1
	echo "Platform is ${PLATFORM}"

	if [ "$PLATFORM" == "iPhoneSimulator" ]; then
		export ARCHITECTURE=i386
		export ARCH=i686-apple-darwin10
	fi

	if [ "$PLATFORM" == "iPhoneOS" ]; then
		export ARCHITECTURE=$2
		export ARCH=arm-apple-darwin10
	fi

        export ARCH_PREFIX=${ARCH}-
        export SDKVER=6.1
        export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer
        export SDKROOT="$DEVROOT/SDKs/${PLATFORM}$SDKVER.sdk"
        export PKG_CONFIG_PATH="$SDKROOT/usr/lib/pkgconfig:$DEVROOT/usr/lib/pkgconfig"
        export AS="$DEVROOT/usr/bin/as"
        export ASCPP="$DEVROOT/usr/bin/as"
        export AR="$DEVROOT/usr/bin/ar"
        export RANLIB="$DEVROOT/usr/bin/ranlib"
        export CPP="$DEVROOT/usr/bin/llvm-cpp-4.2"
        export CXXCPP="$DEVROOT/usr/bin/llvm-cpp-4.2"
        export CC="$DEVROOT/usr/bin/llvm-gcc"
        export CXX="$DEVROOT/usr/bin/llvm-g++"
        export LD="$DEVROOT/usr/bin/ld"
        export STRIP="$DEVROOT/usr/bin/strip"

        export CPPFLAGS="-pipe -no-cpp-precomp -I$SDKROOT/usr/lib/gcc/${ARCH}/4.2.1/include -I$SDKROOT/usr/include -I$DEVROOT/usr/include"
        export CFLAGS="-arch ${ARCHITECTURE} -fmessage-length=0 -pipe -fpascal-strings -no-cpp-precomp -miphoneos-version-min=5.0 --sysroot='$SDKROOT' -isystem $SDKROOT/usr/lib/gcc/${ARCH}/4.2.1/include -isystem $SDKROOT/usr/include -isystem $DEVROOT/usr/include"
        export CXXFLAGS="$CFLAGS -I$SDKROOT/usr/include/c++/4.2.1/${ARCH}/v7"
        export LDFLAGS="-arch ${ARCHITECTURE} --sysroot='$SDKROOT' -L$SDKROOT/usr/lib -L$SDKROOT/usr/lib/system"

        # we need to use clang and libc++
        export CC=clang
        export CXX=clang++
        export CXXFLAGS="$CXXFLAGS -stdlib=libc++"

        ../configure --host=${ARCH} --with-protoc=protoc --enable-static --disable-shared --prefix=/tmp/protobuf/arm
}

mkdir ios-build

# build for simulator
configure_for_platform iPhoneSimulator
make clean
make
cp src/.libs/libprotobuf.a ios-build/libprotobuf-i386.a

# build for arm
configure_for_platform iPhoneOS armv7
make clean
make
cp src/.libs/libprotobuf.a ios-build/libprotobuf-armv7.a

# make a fat library
echo "creating fat library"
xcrun -sdk iphoneos lipo -arch armv7 ios-build/libprotobuf-armv7.a -arch i386 ios-build/libprotobuf-i386.a -create -output ios-build/libprotobuf.a
