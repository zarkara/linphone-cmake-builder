############################################################################
# LinphoneCMakeBuilder.cmake
# Copyright (C) 2014  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
############################################################################

include(ExternalProject)


set(LINPHONE_BUILDER_PKG_CONFIG_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)

set(LINPHONE_BUILDER_EP_VARS)

macro(linphone_builder_expand_external_project_vars)
  set(LINPHONE_BUILDER_EP_ARGS "")
  set(LINPHONE_BUILDER_EP_VARNAMES "")
  foreach(arg ${LINPHONE_BUILDER_EP_VARS})
    string(REPLACE ":" ";" varname_and_vartype ${arg})
    set(target_info_list ${target_info_list})
    list(GET varname_and_vartype 0 _varname)
    list(GET varname_and_vartype 1 _vartype)
    list(APPEND LINPHONE_BUILDER_EP_ARGS -D${_varname}:${_vartype}=${${_varname}})
    list(APPEND LINPHONE_BUILDER_EP_VARNAMES ${_varname})
  endforeach()
endmacro(linphone_builder_expand_external_project_vars)

list(APPEND LINPHONE_BUILDER_EP_VARS
	CMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH
	CMAKE_BUILD_TYPE:STRING
	CMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH
	CMAKE_C_COMPILER:PATH
	CMAKE_C_FLAGS_DEBUG:STRING
	CMAKE_C_FLAGS_MINSIZEREL:STRING
	CMAKE_C_FLAGS_RELEASE:STRING
	CMAKE_C_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_C_FLAGS:STRING
	CMAKE_CROSSCOMPILING:BOOL
	CMAKE_CXX_COMPILER:PATH
	CMAKE_CXX_FLAGS_DEBUG:STRING
	CMAKE_CXX_FLAGS_MINSIZEREL:STRING
	CMAKE_CXX_FLAGS_RELEASE:STRING
	CMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_CXX_FLAGS:STRING
	CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING
	CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING
	CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING
	CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_EXE_LINKER_FLAGS:STRING
	CMAKE_EXTRA_GENERATOR:STRING
	CMAKE_FIND_ROOT_PATH:PATH
	CMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING
	CMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING
	CMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING
	CMAKE_GENERATOR:STRING
	CMAKE_INSTALL_PREFIX:PATH
	CMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH
	CMAKE_MODULE_LINKER_FLAGS_DEBUG:STRING
	CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL:STRING
	CMAKE_MODULE_LINKER_FLAGS_RELEASE:STRING
	CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_MODULE_LINKER_FLAGS:STRING
	CMAKE_MODULE_PATH:PATH
	CMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH
	CMAKE_SHARED_LINKER_FLAGS_DEBUG:STRING
	CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL:STRING
	CMAKE_SHARED_LINKER_FLAGS_RELEASE:STRING
	CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_SHARED_LINKER_FLAGS:STRING
	CMAKE_SKIP_RPATH:BOOL
	CMAKE_SYSTEM_NAME:STRING
	CMAKE_SYSTEM_PROCESSOR:STRING
	CMAKE_VERBOSE_MAKEFILE:BOOL
	LINPHONE_BUILDER_TOOLCHAIN:STRING
)
if(APPLE)
	list(APPEND LINPHONE_BUILDER_EP_VARS
		CMAKE_OSX_ARCHITECTURES:STRING
		CMAKE_OSX_DEPLOYMENT_TARGET:STRING
	)
endif(APPLE)


macro(linphone_builder_apply_toolchain_flags)
	foreach(BUILD_CONFIG "" "_DEBUG" "_MINSIZEREL" "_RELEASE" "_RELWITHDEBINFO")
		if(NOT "${LINPHONE_BUILDER_TOOLCHAIN_CPPFLAGS}" STREQUAL "")
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_CPPFLAGS}")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_CPPFLAGS}")
		endif(NOT "${LINPHONE_BUILDER_TOOLCHAIN_CPPFLAGS}" STREQUAL "")
		if(NOT "${LINPHONE_BUILDER_TOOLCHAIN_CFLAGS}" STREQUAL "")
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_CFLAGS}")
		endif(NOT "${LINPHONE_BUILDER_TOOLCHAIN_CFLAGS}" STREQUAL "")
		if(NOT "${LINPHONE_BUILDER_TOOLCHAIN_CXXFLAGS}" STREQUAL "")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_CXXFLAGS}")
		endif(NOT "${LINPHONE_BUILDER_TOOLCHAIN_CXXFLAGS}" STREQUAL "")
		if(NOT "${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}" STREQUAL "")
			# TODO: The two following lines should not be here
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}")

			set(CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}")
			set(CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}")
			set(CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}")
		endif(NOT "${LINPHONE_BUILDER_TOOLCHAIN_LDFLAGS}" STREQUAL "")
	endforeach(BUILD_CONFIG)
endmacro(linphone_builder_apply_toolchain_flags)


macro(linphone_builder_apply_extra_flags EXTRA_CFLAGS EXTRA_CXXFLAGS EXTRA_LDFLAGS)
	foreach(BUILD_CONFIG "" "_DEBUG" "_MINSIZEREL" "_RELEASE" "_RELWITHDEBINFO")
		if(NOT "${EXTRA_CFLAGS}" STREQUAL "")
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${EXTRA_CFLAGS}")
		endif(NOT "${EXTRA_CFLAGS}" STREQUAL "")
		if(NOT "${EXTRA_CXXFLAGS}" STREQUAL "")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${EXTRA_CXXFLAGS}")
		endif(NOT "${EXTRA_CXXFLAGS}" STREQUAL "")
		if(NOT "${EXTRA_LDFLAGS}" STREQUAL "")
			set(CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG}} ${EXTRA_LDFLAGS}")
			set(CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG}} ${EXTRA_LDFLAGS}")
			set(CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG}} ${EXTRA_LDFLAGS}")
		endif(NOT "${EXTRA_LDFLAGS}" STREQUAL "")
	endforeach(BUILD_CONFIG)
endmacro(linphone_builder_apply_extra_flags)


macro(linphone_builder_add_cmake_project PROJNAME)
	set(EP_${PROJNAME}_SOURCE_DIR "" CACHE PATH "Build ${PROJNAME} from a local source path instead of cloning a repository.")

	linphone_builder_apply_extra_flags("${EP_${PROJNAME}_EXTRA_CFLAGS}" "${EP_${PROJNAME}_EXTRA_CXXFLAGS}" "${EP_${PROJNAME}_EXTRA_LDFLAGS}")
	linphone_builder_expand_external_project_vars()

	if(NOT "${EP_${PROJNAME}_SOURCE_DIR}" STREQUAL "")
		ExternalProject_Add(EP_${PROJNAME}
			DEPENDS ${EP_${PROJNAME}_DEPENDENCIES}
			SOURCE_DIR ${EP_${PROJNAME}_SOURCE_DIR}
			PATCH_COMMAND ${EP_${PROJNAME}_PATCH_COMMAND}
			CMAKE_ARGS ${EP_${PROJNAME}_CMAKE_OPTIONS}
			CMAKE_CACHE_ARGS ${LINPHONE_BUILDER_EP_ARGS}
		)
	else(NOT "${EP_${PROJNAME}_SOURCE_DIR}" STREQUAL "")
 		ExternalProject_Add(EP_${PROJNAME}
			DEPENDS ${EP_${PROJNAME}_DEPENDENCIES}
 			GIT_REPOSITORY ${EP_${PROJNAME}_GIT_REPOSITORY}
 			GIT_TAG ${EP_${PROJNAME}_GIT_TAG}
 			PATCH_COMMAND ${EP_${PROJNAME}_PATCH_COMMAND}
 			CMAKE_ARGS ${EP_${PROJNAME}_CMAKE_OPTIONS}
			CMAKE_CACHE_ARGS ${LINPHONE_BUILDER_EP_ARGS}
 		)
 	endif(NOT "${EP_${PROJNAME}_SOURCE_DIR}" STREQUAL "")
endmacro(linphone_builder_add_cmake_project)

macro(linphone_builder_add_autotools_project PROJNAME)
	linphone_builder_apply_extra_flags("${EP_${PROJNAME}_EXTRA_CFLAGS}" "${EP_${PROJNAME}_EXTRA_CXXFLAGS}" "${EP_${PROJNAME}_EXTRA_LDFLAGS}")
	linphone_builder_expand_external_project_vars()

	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/configure.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.sh)
	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/build.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.sh)
	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/install.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.sh)

	if(NOT "${EP_${PROJNAME}_SOURCE_DIR}" STREQUAL "")
		ExternalProject_Add(EP_${PROJNAME}
			DEPENDS ${EP_${PROJNAME}_DEPENDENCIES}
			SOURCE_DIR ${EP_${PROJNAME}_SOURCE_DIR}
			PATCH_COMMAND ${EP_${PROJNAME}_PATCH_COMMAND}
			CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.sh
			BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.sh
			INSTALL_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.sh
			BUILD_IN_SOURCE 1
		)
	else(NOT "${EP_${PROJNAME}_SOURCE_DIR}" STREQUAL "")
		ExternalProject_Add(EP_${PROJNAME}
			DEPENDS ${EP_${PROJNAME}_DEPENDENCIES}
			GIT_REPOSITORY ${EP_${PROJNAME}_GIT_REPOSITORY}
			GIT_TAG ${EP_${PROJNAME}_GIT_TAG}
			PATCH_COMMAND ${EP_${PROJNAME}_PATCH_COMMAND}
			CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.sh
			BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.sh
			INSTALL_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.sh
			BUILD_IN_SOURCE 1
		)
	endif(NOT "${EP_${PROJNAME}_SOURCE_DIR}" STREQUAL "")
endmacro(linphone_builder_add_autotools_project PROJNAME)
