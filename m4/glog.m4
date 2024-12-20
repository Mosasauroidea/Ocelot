dnl @synopsis GLOG_DEVEL
dnl 
dnl This macro tries to find the libgoogle-glog-dev library and header files.
dnl
dnl We define the following configure script flags:
dnl
dnl		--with-glog: Give prefix for both library and headers, and try
dnl			to guess subdirectory names for each.  (e.g. tack /lib and
dnl			/include onto given dir name, and other common schemes.)
dnl		--with-ev-lib: Similar to --with-ev, but for library only.
dnl		--with-ev-include: Similar to --with-ev, but for headers only.

AC_DEFUN([GLOG_DEVEL],
[
	dnl
	dnl Set up configure script macros
	dnl
	AC_ARG_WITH(glog,
		[AS_HELP_STRING([--with-glog=<path>],[path containing libgoogle-glog-dev header and library subdirs])],
		[GLOG_lib_check="$with_glog/lib64 $with_glog/lib $with_glog/lib64/libglog $with_glog/lib/libglog"
		  GLOG_inc_check="$with_glog/include $with_glog/include/libglog"],
		[GLOG_lib_check="/usr/local/libglog/lib64 /usr/local/libglog/lib /usr/local/lib64/libglog /usr/local/lib/libglog /opt/libglog/lib64 /opt/libglog/lib /usr/lib64/libglog /usr/lib/libglog /usr/local/lib64 /usr/local/lib /usr/lib64 /usr/lib"
		  GLOG_inc_check="/usr/local/libglog/include /usr/local/include/libglog /opt/libglog/include /usr/local/include/libglog /usr/local/include /usr/include/libglog /usr/include"])
	AC_ARG_WITH(glog-lib,
    		[AS_HELP_STRING([--with-glog-lib=<path>],[directory path of libglog library])],
    		[GLOG_lib_check="$with_glog_lib $with_glog_lib/lib64 $with_glog_lib/lib $with_glog_lib/lib64/glog $with_glog_lib/lib/glog"])
    AC_ARG_WITH(glog-include,
    		[AS_HELP_STRING([--with-glog-include=<path>],[directory path of libev headers])],
    		[GLOG_inc_check="$with_glog_include $with_glog_include/include $with_glog_include/include/glog"])

	dnl
	dnl Look for libglog library
	dnl
	AC_CACHE_CHECK([for libglog library location], [ac_cv_glog_lib],
	[
		for dir in $GLOG_lib_check
		do
			if test -d "$dir" && \
				( test -f "$dir/libglog.so" ||
				  test -f "$dir/libglog.a" )
			then
				ac_cv_glog_lib=$dir
				break
			fi
		done

		if test -z "$ac_cv_glog_lib"
		then
			AC_MSG_RESULT([no])
			AC_MSG_ERROR([Didn't find the libglog library dir in '$GLOG_lib_check'])
		fi

		case "$ac_cv_glog_lib" in
			/* )
				;;
			* )
				AC_MSG_RESULT([])
				AC_MSG_ERROR([The libglog library directory ($ac_cv_glog_lib) must be an absolute path.])
				;;
		esac
	])
	AC_SUBST([GLOG_LIB_DIR],[$ac_cv_glog_lib])

	dnl
	dnl Look for libglog header file directory
	dnl
	AC_CACHE_CHECK([for libglog include path], [ac_cv_glog_inc],
	[
		for dir in $GLOG_inc_check
		do
			if test -d "$dir" && test -f "$dir/ev++.h"
			then
				ac_cv_glog_inc=$dir
				break
			fi
		done

		if test -z "$ac_cv_glog_inc"
		then
			AC_MSG_RESULT([no])
			AC_MSG_ERROR([Didn't find the libglog header dir in '$GLOG_inc_check'])
		fi

		case "$ac_cv_glog_inc" in
			/* )
				;;
			* )
				AC_MSG_RESULT([])
				AC_MSG_ERROR([The libglog header directory ($ac_cv_glog_inc) must be an absolute path.])
				;;
		esac
	])
	AC_SUBST([GLOG_INC_DIR],[$ac_cv_glog_inc])

	dnl
	dnl Now check that the above checks resulted in -I and -L flags that
	dnl let us build actual programs against libglog.
	dnl
	case "$ac_cv_glog_lib" in
		/usr/lib)
			;;
		*)
			LDFLAGS="$LDFLAGS -L${ac_cv_glog_lib}"
			;;
	esac
	CPPFLAGS="$CPPFLAGS -I${ac_cv_glog_inc}"
	AC_MSG_CHECKING([that we can build libglog programs])

	LIBS="-lglog $LIBS"
	AC_LANG_PUSH([C++])
	AC_LINK_IFELSE(
		[AC_LANG_PROGRAM(
			[#include <glog/logging.h>],
			[LOG(INFO) << "Hello world!"])
		],
		[AC_MSG_RESULT([yes])],
		[AC_MSG_RESULT([no])
			AC_MSG_FAILURE([Cannot build libglog programs])]
	)
	AC_LANG_POP([C++])
]) dnl End GLOG_DEVEL

