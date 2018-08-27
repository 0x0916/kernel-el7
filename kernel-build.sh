#!/usr/bin/env bash

# kernel build script
#
# Copyright © 2017 Wang Long <w@laoqinren.net>

set -e

function usage() {
	cat <<EOF
Descrition:
	kernel build script
Author:
	Wang Long (w@laoqinren.net)
Usage:
	$0 [-f]
Optional arguments:
	[-h | --help ]: Print this help message and exit.
	[-f | --full ]: Build all the kernel rpms.

EOF
	return 0
}

if ! options=$(getopt -o hf -l full,url: -- "$@"); then
	usage
	exit 1
fi

eval set -- "$options"

while :; do
	case "$1" in
		-h|--help)	usage && exit 1;;
		-f|--full)	BUILD_FULL="true"; shift 1;;
		*)		break;
	esac
done

BASEDIR=$(cd `dirname $0`; pwd)
BUILDDIR=$BASEDIR

if [ "$BUILD_FULL" = "true" ]; then
	echo "Build all kernel rpms"
	rpmbuild -ba $BUILDDIR/SPECS/kernel-ml-4.18.spec --without kabichk --define="_topdir $BUILDDIR" --define="_smp_mflags -j40"  2>&1 | tee $BUILDDIR/build.log
else
	echo "Build only base kernel rpms"
	rpmbuild -ba $BUILDDIR/SPECS/kernel-ml-4.18.spec --define="_topdir $BUILDDIR" --with baseonly --without debug --without debuginfo --without kdump --without perf --without tools --without headers --without doc --without bootwrapper --without kabichk --define="_smp_mflags -j40" 2>&1 | tee $BUILDDIR/build.log
fi

echo "kernel build successfully...."
echo "The RPMS located in DIR: $BUILDDIR/RPMS/x86_64/"
ls -l $BUILDDIR/RPMS/x86_64/
echo "The Kernel Source RPM located in DIR: $BUILDDIR/SRPMS/"
ls -l $BUILDDIR/SRPMS/
