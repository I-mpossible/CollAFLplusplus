#!/bin/sh

case $1 in
	p|plot)
		cp /home/vmuser/lava_corpus/LAVA-M/base64/outputs/plot_data /home/vmuser/plot/base64_cache
		cp /home/vmuser/original/lava_corpus/LAVA-M/base64/outputs/plot_data /home/vmuser/plot/base64_origin

		cp /home/vmuser/lava_corpus/LAVA-M/md5sum/outputs/plot_data /home/vmuser/plot/md5sum_cache
		cp /home/vmuser/original/lava_corpus/LAVA-M/md5sum/outputs/plot_data /home/vmuser/plot/md5sum_origin

		cp /home/vmuser/lava_corpus/LAVA-M/uniq/outputs/plot_data /home/vmuser/plot/uniq_cache
		cp /home/vmuser/original/lava_corpus/LAVA-M/uniq/outputs/plot_data /home/vmuser/plot/uniq_origin

		cp /home/vmuser/lava_corpus/LAVA-M/who/outputs/plot_data /home/vmuser/plot/who_cache
		cp /home/vmuser/original/lava_corpus/LAVA-M/who/outputs/plot_data /home/vmuser/plot/who_origin

		cp /home/vmuser/libpng-1.6.36/outputs/plot_data /home/vmuser/plot/libpng_cache
		cp /home/vmuser/original/libpng-1.6.36/outputs/plot_data /home/vmuser/plot/libpng_origin

		cp /home/vmuser/tiff-4.1.0/outputs/plot_data /home/vmuser/plot/tiff_cache
		cp /home/vmuser/original/tiff-4.1.0/outputs/plot_data /home/vmuser/plot/tiff_origin

		cp /home/vmuser/ffmpeg/outputs/plot_data /home/vmuser/plot/ffmpeg_cache
		cp /home/vmuser/original/ffmpeg/outputs/plot_data /home/vmuser/plot/ffmpeg_origin

		cp /home/vmuser/binutils-2.35/outputs/plot_data /home/vmuser/plot/objdump_cache
		cp /home/vmuser/original/binutils-2.35/outputs/plot_data /home/vmuser/plot/objdump_origin
		exit 0
	;;
esac

case $# in
	3)
		mode=$1
		binary=$2
		operation=$3
	;;
	4)
		mode=$1
		binary=$2
		operation=$3
		mapsize=$4
		echo $mapsize
		export AFL_MAP_SIZE=$mapsize
		echo $AFL_MAP_SIZE
	;;
	*)
		echo $#
		echo "usage: ./fuzz.sh [cache(c)|origin(o)] [libpng(l)|base64(b)] [build(b)|run(r)]"
		exit 1
	;;
esac


case $mode in
	c|cache)
		prefix="$HOME/"
	;;
	o|origin)
		prefix="$HOME/original/"
	;;
	*)
		echo "Unsupported mode"
		exit 1
	;;
esac

case $binary in
	l|libpng)
		path="libpng-1.6.36/"
		suffix=""
	;;
	tiff)
		path="tiff-4.1.0/"
		suffix=""
	;;
	b|base64)
		path="lava_corpus/LAVA-M/base64/"
		suffix="coreutils-8.24-lava-safe/"
	;;
	uniq)
		path="lava_corpus/LAVA-M/uniq/"
		suffix="coreutils-8.24-lava-safe/"
	;;
	md5sum)
		path="lava_corpus/LAVA-M/md5sum/"
		suffix="coreutils-8.24-lava-safe/"
	;;
	who)
		path="lava_corpus/LAVA-M/who/"
		suffix="coreutils-8.24-lava-safe/"
	;;
	la|libav)
		path="libav-12.3/"
		suffix=""
	;;
	objdump)
		path="binutils-2.35/"
		suffix=""
	;;
	ffmpeg)
		path="ffmpeg/"
		suffix=""
	;;
	*)
		echo "Unsupported binary"
		exit 1
	;;
esac

case $operation in
	b|build)
		cd ${prefix}${path}${suffix}
		export AFL_LLVM_INSTRUMENT=coll
		case $binary in
			l|libpng)
				make clean all -j4
			;;
			tiff)
				make clean
				make
			;;
			b|base64)
				rm src/base64
				make src/base64 -j4
			;;
			uniq)
				rm src/uniq
				make src/uniq -j4
			;;
			md5sum)
				rm src/md5sum
				make src/md5sum -j4
			;;
			who)
				rm src/who
				make src/who -j4
			;;
			la|libav)
				make clean all -j4
			;;
			objdump)
				rm binutils/objdump
				make -j8
			;;
			ffmpeg)
				rm ffmpeg
				make -j8
			;;
			*)
				echo "Unsupported binary"
				exit 1
			;;
		esac
	;;
	r|run)
		cd ${prefix}${path}
		case $binary in
			l|libpng)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/png/full/images -o outputs/ ./pngvalid @@
			;;
			tiff)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/tiff/full/images -o outputs/ tools/tiff2pdf @@
			;;
			b|base64)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/ -o outputs/ -- coreutils-8.24-lava-safe/src/base64 -d @@
			;;
			uniq)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/ -o outputs/ -- coreutils-8.24-lava-safe/src/uniq @@
			;;
			md5sum)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/ -o outputs/ -- coreutils-8.24-lava-safe/src/md5sum -c @@
			;;
			who)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/ -o outputs/ -- coreutils-8.24-lava-safe/src/who @@
			;;
			objdump)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/ -o outputs/ -- binutils/objdump -s @@
			;;
			ffmpeg)
				${prefix}CollAFLplusplus/afl-fuzz -i fuzzer_input/ -o outputs/ ./ffmpeg -i @@
			;;
			*)
				echo "Unsupported binary"
				exit 1
			;;
		esac
	;;
	reconfigure)
		case $binary in
			l|libpng)
				case $mode in
					c|cache)
						cd ~/libpng-1.6.36
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --enable-static --disable-shared
					;;
					o|origin)
						cd ~/original/libpng-1.6.36
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --enable-static --disable-shared
					;;
				esac
			;;
			tiff)
				case $mode in
					c|cache)
						cd ~/tiff-4.1.0
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --enable-static --disable-shared
					;;
					o|origin)
						cd ~/original/tiff-4.1.0
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --enable-static --disable-shared
					;;
				esac
			;;
			b|base64)
				case $mode in
					c|cache)
						cd ~/lava_corpus/LAVA-M/base64/coreutils-8.24-lava-safe
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
					o|origin)
						cd ~/original/lava_corpus/LAVA-M/base64/coreutils-8.24-lava-safe
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
				esac
			;;
			uniq)
				case $mode in
					c|cache)
						cd ~/lava_corpus/LAVA-M/uniq/coreutils-8.24-lava-safe
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
					o|origin)
						cd ~/original/lava_corpus/LAVA-M/uniq/coreutils-8.24-lava-safe
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
				esac
			;;
			md5sum)
				case $mode in
					c|cache)
						cd ~/lava_corpus/LAVA-M/md5sum/coreutils-8.24-lava-safe
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
					o|origin)
						cd ~/original/lava_corpus/LAVA-M/md5sum/coreutils-8.24-lava-safe
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
				esac
			;;
			who)
				case $mode in
					c|cache)
						cd ~/lava_corpus/LAVA-M/who/coreutils-8.24-lava-safe
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
					o|origin)
						cd ~/original/lava_corpus/LAVA-M/who/coreutils-8.24-lava-safe
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure --prefix=`pwd`/lava-install LIBS="-lacl"
					;;
				esac
			;;
			la|libav)
				case $mode in
					c|cache)
						cd ~/libav-12.3
						AFL_LLVM_INSTRUMENT=coll ./configure --cc=$HOME/CollAFLplusplus/afl-clang-lto --enable-static
					;;
					o|origin)
						cd ~/original/libav-12.3
						AFL_LLVM_INSTRUMENT=coll ./configure --cc=$HOME/original/CollAFLplusplus/afl-clang-lto --enable-static
					;;
				esac
			;;
			objdump)
				case $mode in
					c|cache)
						cd ~/binutils-2.35
						CC=~/CollAFLplusplus/afl-clang-lto CXX=~/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure
					;;
					o|origin)
						cd ~/original/binutils-2.35
						CC=~/original/CollAFLplusplus/afl-clang-lto CXX=~/original/CollAFLplusplus/afl-clang-lto++ AFL_LLVM_INSTRUMENT=coll ./configure
					;;
				esac
			;;
			ff|ffmpeg)
				case $mode in
					c|cache)
						cd ~/libav-12.3
						AFL_LLVM_INSTRUMENT=coll ./configure --cc=$HOME/CollAFLplusplus/afl-clang-lto --enable-static
					;;
					o|origin)
						cd ~/original/libav-12.3
						AFL_LLVM_INSTRUMENT=coll ./configure --cc=$HOME/original/CollAFLplusplus/afl-clang-lto --enable-static
					;;
				esac
			;;
			*)
				echo "Unsupported binary"
				exit 1
			;;
		esac
	;;
	*)
		echo "Unsupported operation"
		exit 1
	;;
esac



