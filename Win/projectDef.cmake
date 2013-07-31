##
# Linphone Web - Web plugin of Linphone an audio/video SIP phone
# Copyright (C) 2012  Yann Diorcet <yann.diorcet@linphone.org>
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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
##

# Windows template platform definition CMake file
# Included from ../CMakeLists.txt
INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/Common/common.cmake)

# remember that the current source dir is the project root; this file is in Win/
FILE(GLOB PLATFORM RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
	Win/[^.]*.cpp
	Win/[^.]*.h
	Win/[^.]*.cmake
)

# use this to add preprocessor definitions
ADD_DEFINITIONS(
	/D "_ATL_STATIC_REGISTRY"
	/wd4355
	/D "CORE_THREADED"
)

SOURCE_GROUP(Win FILES ${PLATFORM})

SET(SOURCES
	${SOURCES}
	${PLATFORM}
)

SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE
		"/LTCG /SUBSYSTEM:WINDOWS /OPT:NOREF /OPT:ICF")
SET(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
		"/LTCG /SUBSYSTEM:WINDOWS /OPT:NOREF /OPT:ICF")
SET(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
		"/LTCG /SUBSYSTEM:WINDOWS /OPT:NOREF /OPT:ICF")

INCLUDE_DIRECTORIES(Rootfs/include)

add_windows_plugin(${PROJECT_NAME} SOURCES)
SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES FOLDER ${FBSTRING_ProductName})

# add library dependencies here; leave ${PLUGIN_INTERNAL_DEPS} there unless you know what you're doing!
TARGET_LINK_LIBRARIES(${PROJECT_NAME}
	${PLUGIN_INTERNAL_DEPS}
	"${CMAKE_CURRENT_SOURCE_DIR}/Rootfs/lib/liblinphone-5.lib"
	"${CMAKE_CURRENT_SOURCE_DIR}/Rootfs/lib/libmediastreamer_base-3.lib"
	"${CMAKE_CURRENT_SOURCE_DIR}/Rootfs/lib/libmediastreamer_voip-3.lib"
	"${CMAKE_CURRENT_SOURCE_DIR}/Rootfs/lib/libortp-9.lib")

SET(LINPHONEWEB_SHAREDIR linphoneweb)
SET(FB_PACKAGE_SUFFIX Win)
IF(FB_PLATFORM_ARCH_64)
	SET(FB_PACKAGE_SUFFIX "${FB_PACKAGE_SUFFIX}64")
ELSE(FB_PLATFORM_ARCH_64)
	SET(FB_PACKAGE_SUFFIX "${FB_PACKAGE_SUFFIX}32")
ENDIF(FB_PLATFORM_ARCH_64)

SET(DEPENDENCY_EXT "dll")
SET(PLUGIN_EXT "dll")
SET(FB_OUT_DIR ${FB_BIN_DIR}/${PLUGIN_NAME}/${CMAKE_CFG_INTDIR})
SET(FB_ROOTFS_DIR ${FB_OUT_DIR}/Rootfs)
SET(WIX_LINK_FLAGS -dConfiguration=${CMAKE_CFG_INTDIR})

###############################################################################
# Create Rootfs
if (NOT FB_ROOTFS_SUFFIX)
	SET(FB_ROOTFS_SUFFIX _RootFS)
endif()

function (create_rootfs PROJNAME)
	# Define components
	SET(ROOTFS_LIB_SOURCES
		liblinphone-5.${DEPENDENCY_EXT}
		libmediastreamer_base-3.${DEPENDENCY_EXT}
		libmediastreamer_voip-3.${DEPENDENCY_EXT}
		libogg-0.${DEPENDENCY_EXT}
		libortp-9.${DEPENDENCY_EXT}
		libspeex-1.${DEPENDENCY_EXT}
		libspeexdsp-1.${DEPENDENCY_EXT}
		libtheora-0.${DEPENDENCY_EXT}
		libvpx-1.${DEPENDENCY_EXT}
		libz-1.${DEPENDENCY_EXT}
	)
	IF(LW_USE_SRTP)
		SET(ROOTFS_LIB_SOURCES
			${ROOTFS_LIB_SOURCES}
			libsrtp-1.4.5.${DEPENDENCY_EXT}
		)
	ENDIF(LW_USE_SRTP)
	IF(LW_USE_OPENSSL)
		SET(ROOTFS_LIB_SOURCES
			${ROOTFS_LIB_SOURCES}
			libeay32.${DEPENDENCY_EXT}
			ssleay32.${DEPENDENCY_EXT}
		)
	ENDIF(LW_USE_OPENSSL)
	IF(LW_USE_EXOSIP)
		SET(ROOTFS_LIB_SOURCES
			${ROOTFS_LIB_SOURCES}
			libeXosip2-7.${DEPENDENCY_EXT}
			libosip2-7.${DEPENDENCY_EXT}
			libosipparser2-7.${DEPENDENCY_EXT}
		)
	ENDIF(LW_USE_EXOSIP)
	IF(LW_USE_FFMPEG)
		SET(ROOTFS_LIB_SOURCES
			${ROOTFS_LIB_SOURCES}
			avcodec-53.${DEPENDENCY_EXT}
			avutil-51.${DEPENDENCY_EXT}
			swscale-2.${DEPENDENCY_EXT}
		)
	ENDIF(LW_USE_FFMPEG)
	IF(LW_USE_POLARSSL)
		SET(ROOTFS_LIB_SOURCES
			${ROOTFS_LIB_SOURCES}
			libpolarssl-0.${DEPENDENCY_EXT}
		)
	ENDIF(LW_USE_POLARSSL)
	IF(LW_USE_BELLESIP)
		SET(ROOTFS_LIB_SOURCES
			${ROOTFS_LIB_SOURCES}
			libbellesip-0.${DEPENDENCY_EXT}
			libantlr3c-0.${DEPENDENCY_EXT}
			libxml2-2.${DEPENDENCY_EXT}
		)
	ENDIF(LW_USE_BELLESIP)

	SET(ROOTFS_SHARE_SOURCES
		linphone/rootca.pem
		images/nowebcamCIF.jpg
		sounds/linphone/ringback.wav
		sounds/linphone/rings/oldphone.wav
		sounds/linphone/rings/toy-mono.wav
	)

	# Set Rootfs sources
	SET(ROOTFS_SOURCES
		${FB_OUT_DIR}/${FBSTRING_PluginFileName}.${PLUGIN_EXT}
	)
	FOREACH(elem ${ROOTFS_LIB_SOURCES})
		SET(DIR_SRC ${CMAKE_CURRENT_SOURCE_DIR}/Rootfs/bin)
		SET(DIR_DEST ${FB_ROOTFS_DIR})
		GET_FILENAME_COMPONENT(path ${elem} PATH)
		ADD_CUSTOM_COMMAND(OUTPUT ${DIR_DEST}/${elem} 
			DEPENDS ${DIR_SRC}/${elem}
			COMMAND ${CMAKE_COMMAND} -E make_directory ${DIR_DEST}/${path}
			COMMAND ${CMAKE_COMMAND} -E copy ${DIR_SRC}/${elem} ${DIR_DEST}/${elem}
		)
		LIST(APPEND ROOTFS_SOURCES ${DIR_DEST}/${elem})
	ENDFOREACH(elem ${ROOTFS_LIB_SOURCES})
	FOREACH(elem ${ROOTFS_SHARE_SOURCES})
		SET(DIR_SRC ${CMAKE_CURRENT_SOURCE_DIR}/Rootfs/share)
		SET(DIR_DEST ${FB_ROOTFS_DIR}/${LINPHONEWEB_SHAREDIR}/share)
		GET_FILENAME_COMPONENT(path ${elem} PATH)
		ADD_CUSTOM_COMMAND(OUTPUT ${DIR_DEST}/${elem} 
			DEPENDS ${DIR_SRC}/${elem}
			COMMAND ${CMAKE_COMMAND} -E make_directory ${DIR_DEST}/${path}
			COMMAND ${CMAKE_COMMAND} -E copy ${DIR_SRC}/${elem} ${DIR_DEST}/${elem}
		)
		LIST(APPEND ROOTFS_SOURCES ${DIR_DEST}/${elem})
	ENDFOREACH(elem ${ROOTFS_SHARE_SOURCES})

	ADD_CUSTOM_COMMAND(OUTPUT ${FB_OUT_DIR}/Rootfs.updated 
		DEPENDS ${ROOTFS_SOURCES}
		COMMAND ${CMAKE_COMMAND} -E copy ${FB_OUT_DIR}/${FBSTRING_PluginFileName}.pdb ${FB_ROOTFS_DIR}/ || ${CMAKE_COMMAND} -E echo "No pdb"
		COMMAND ${CMAKE_COMMAND} -E copy ${FB_OUT_DIR}/${FBSTRING_PluginFileName}.${PLUGIN_EXT} ${FB_ROOTFS_DIR}/

		COMMAND ${CMAKE_COMMAND} -E touch ${FB_OUT_DIR}/Rootfs.updated
	)
	
	ADD_CUSTOM_TARGET(${PROJNAME}${FB_ROOTFS_SUFFIX} ALL DEPENDS ${FB_OUT_DIR}/Rootfs.updated)
	SET_TARGET_PROPERTIES(${PROJNAME}${FB_ROOTFS_SUFFIX} PROPERTIES FOLDER ${FBSTRING_ProductName})
	ADD_DEPENDENCIES(${PROJNAME}${FB_ROOTFS_SUFFIX} ${PROJNAME})
	MESSAGE("-- Successfully added Rootfs step")
endfunction(create_rootfs)
###############################################################################

create_rootfs(${PLUGIN_NAME})

# Sign generated file
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/${FBSTRING_PluginFileName}.${PLUGIN_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)

# Sign dll dependencies

IF(LW_USE_FFMPEG)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/avcodec-53.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/avutil-51.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/swscale-2.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
ENDIF(LW_USE_FFMPEG)

my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libeXosip2-7.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libeay32.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/liblinphone-5.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libmediastreamer_base-3.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libmediastreamer_voip-3.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libogg-0.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libortp-9.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libosip2-7.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libosipparser2-7.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libspeex-1.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libspeexdsp-1.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libtheora-0.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libvpx-1.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/libz-1.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)
my_sign_file(${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	"${FB_ROOTFS_DIR}/ssleay32.${DEPENDENCY_EXT}"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	"http://timestamp.verisign.com/scripts/timestamp.dll"
)


###############################################################################
# MSI & EXE Package
if(WIX_FOUND)
	SET(WIX_HEAT_FLAGS
		-gg                  # Generate GUIDs
		-srd                 # Suppress Root Dir
		-cg PluginDLLGroup   # Set the Component group name
		-dr INSTALLDIR       # Set the directory ID to put the files in
	)
	if (NOT FB_WIX_SUFFIX)
		set (FB_WIX_SUFFIX _MSI)
	endif()
	if (NOT FB_WIX_EXE_SUFFIX)
		set (FB_WIX_EXE_SUFFIX _EXE)
	endif()

	SET(FB_WIX_DEST ${FB_OUT_DIR}/${PLUGIN_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.msi)
	SET(FB_WIX_EXEDEST ${FB_OUT_DIR}/${PLUGIN_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.exe)
	add_wix_installer(${PLUGIN_NAME}
		"${CMAKE_CURRENT_SOURCE_DIR}/Win/WiX/linphoneInstaller.wxs"
		PluginDLLGroup
		${FB_ROOTFS_DIR}/
		"${FB_ROOTFS_DIR}/${FBSTRING_PluginFileName}.${PLUGIN_EXT}"
		${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
	)
	SET_TARGET_PROPERTIES(${PLUGIN_NAME}${FB_WIX_SUFFIX} PROPERTIES FOLDER ${FBSTRING_ProductName})
	SET_TARGET_PROPERTIES(${PLUGIN_NAME}${FB_WIX_EXE_SUFFIX} PROPERTIES FOLDER ${FBSTRING_ProductName})

	my_sign_file(${PLUGIN_NAME}${FB_WIX_SUFFIX}
		"${FB_OUT_DIR}/${PLUGIN_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.msi"
		"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
		"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
		"http://timestamp.verisign.com/scripts/timestamp.dll"
	)

	my_sign_file(${PLUGIN_NAME}${FB_WIX_EXE_SUFFIX}
		"${FB_OUT_DIR}/${PLUGIN_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.exe"
		"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
		"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
		"http://timestamp.verisign.com/scripts/timestamp.dll"
	)
endif()
###############################################################################

###############################################################################
# CAB Package
if(WIX_FOUND)
	SET(FB_CAB_DEST ${FB_OUT_DIR}/${PLUGIN_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.cab)
	if (NOT FB_CAB_SUFFIX)
		set (FB_CAB_SUFFIX _CAB)
	endif()

	create_cab(${PLUGIN_NAME}
		"${CMAKE_CURRENT_SOURCE_DIR}/Win/Wix/linphone-web.ddf"
		"${CMAKE_CURRENT_SOURCE_DIR}/Win/Wix/linphone-web.inf"
		${FB_OUT_DIR}/
		${PLUGIN_NAME}${FB_WIX_EXE_SUFFIX}
	)
	SET_TARGET_PROPERTIES(${PLUGIN_NAME}${FB_CAB_SUFFIX} PROPERTIES FOLDER ${FBSTRING_ProductName})

	my_sign_file(${PLUGIN_NAME}${FB_CAB_SUFFIX}
		"${FB_OUT_DIR}/${PLUGIN_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.cab"
		"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pfx"
		"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
		"http://timestamp.verisign.com/scripts/timestamp.dll"
	)
endif()
###############################################################################

###############################################################################
# XPI Package
if (NOT FB_XPI_PACKAGE_SUFFIX)
	SET(FB_XPI_PACKAGE_SUFFIX _XPI)
endif()

function (create_xpi_package PROJNAME PROJVERSION OUTDIR PROJDEP)
	SET(XPI_SOURCES
		${FB_OUT_DIR}/Rootfs.updated
		${CMAKE_CURRENT_BINARY_DIR}/install.rdf
		${CMAKE_CURRENT_SOURCE_DIR}/Win/XPI/bootstrap.js
		${CMAKE_CURRENT_SOURCE_DIR}/Win/XPI/chrome.manifest
		${CMAKE_CURRENT_SOURCE_DIR}/Common/icon48.png
		${CMAKE_CURRENT_SOURCE_DIR}/Common/icon64.png
	)

	CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/Win/XPI/install.rdf ${CMAKE_CURRENT_BINARY_DIR}/install.rdf)

	SET(FB_PKG_DIR ${FB_OUT_DIR}/XPI)

	ADD_CUSTOM_TARGET(${PROJNAME}${FB_XPI_PACKAGE_SUFFIX} ALL DEPENDS ${OUTDIR}/${PROJNAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.xpi)
	SET_TARGET_PROPERTIES(${PROJNAME}${FB_XPI_PACKAGE_SUFFIX} PROPERTIES FOLDER ${FBSTRING_ProductName})
	ADD_CUSTOM_COMMAND(OUTPUT ${OUTDIR}/${PROJNAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.xpi
				DEPENDS ${XPI_SOURCES}
				COMMAND ${CMAKE_COMMAND} -E remove_directory ${FB_PKG_DIR}
				COMMAND ${CMAKE_COMMAND} -E make_directory ${FB_PKG_DIR}
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/install.rdf ${FB_PKG_DIR}/
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Win/XPI/bootstrap.js ${FB_PKG_DIR}/
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Win/XPI/chrome.manifest ${FB_PKG_DIR}/

				COMMAND ${CMAKE_COMMAND} -E make_directory ${FB_PKG_DIR}/chrome/skin
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Common/icon48.png ${FB_PKG_DIR}/chrome/skin/
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Common/icon64.png ${FB_PKG_DIR}/chrome/skin/

				COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/Common/copy.py ${FB_ROOTFS_DIR} ${FB_PKG_DIR}/plugins

				COMMAND ${CMAKE_COMMAND} -E remove ${OUTDIR}/${PROJNAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.xpi
				COMMAND jar cfM ${OUTDIR}/${PROJNAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.xpi -C ${FB_PKG_DIR} .

				COMMAND ${CMAKE_COMMAND} -E touch ${FB_OUT_DIR}/XPI.updated
	)
	ADD_DEPENDENCIES(${PROJNAME}${FB_XPI_PACKAGE_SUFFIX} ${PROJDEP})
	MESSAGE("-- Successfully added XPI package step")
endfunction(create_xpi_package)

create_xpi_package(${PLUGIN_NAME}
	${FBSTRING_PLUGIN_VERSION}
	${FB_OUT_DIR}
	${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
)

create_signed_xpi(${PLUGIN_NAME}
	"${FB_OUT_DIR}/XPI/"
	"${FB_OUT_DIR}/${PROJECT_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.xpi"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pem"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	${PLUGIN_NAME}${FB_XPI_PACKAGE_SUFFIX}
)
###############################################################################

###############################################################################
# CRX Package
if (NOT FB_CRX_PACKAGE_SUFFIX)
	SET(FB_CRX_PACKAGE_SUFFIX _CRX)
endif()

function (create_crx_package PROJNAME PROJVERSION OUTDIR PROJDEP)
	SET(CRX_SOURCES
		${FB_OUT_DIR}/Rootfs.updated
		${CMAKE_CURRENT_BINARY_DIR}/manifest.json
		${CMAKE_CURRENT_SOURCE_DIR}/Common/icon16.png
		${CMAKE_CURRENT_SOURCE_DIR}/Common/icon48.png
	)

	CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/Win/CRX/manifest.json ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)

	SET(FB_PKG_DIR ${FB_OUT_DIR}/CRX)

	ADD_CUSTOM_TARGET(${PROJNAME}${FB_CRX_PACKAGE_SUFFIX} ALL DEPENDS ${OUTDIR}/${PROJECT_NAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.crx)
	SET_TARGET_PROPERTIES(${PROJNAME}${FB_CRX_PACKAGE_SUFFIX} PROPERTIES FOLDER ${FBSTRING_ProductName})
	ADD_CUSTOM_COMMAND(OUTPUT ${OUTDIR}/${PROJECT_NAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.crx
				DEPENDS ${CRX_SOURCES}
				COMMAND ${CMAKE_COMMAND} -E remove_directory ${FB_PKG_DIR}
				COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/Common/copy.py ${FB_ROOTFS_DIR} ${FB_PKG_DIR}
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/manifest.json ${FB_PKG_DIR}/
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Common/icon16.png ${FB_PKG_DIR}/
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Common/icon48.png ${FB_PKG_DIR}/

				COMMAND ${CMAKE_COMMAND} -E remove ${OUTDIR}/${PROJECT_NAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.crx
				COMMAND jar cfM ${OUTDIR}/${PROJECT_NAME}-${PROJVERSION}-${FB_PACKAGE_SUFFIX}-unsigned.crx -C ${FB_PKG_DIR} .

				COMMAND ${CMAKE_COMMAND} -E touch ${FB_OUT_DIR}/CRX.updated
	)
	ADD_DEPENDENCIES(${PROJNAME}${FB_CRX_PACKAGE_SUFFIX} ${PROJDEP})
	MESSAGE("-- Successfully added CRX package step")
endfunction(create_crx_package)

create_crx_package(${PLUGIN_NAME}
	${FBSTRING_PLUGIN_VERSION}
	${FB_OUT_DIR}
	${PLUGIN_NAME}${FB_ROOTFS_SUFFIX}
)

create_signed_crx(${PLUGIN_NAME}
	"${FB_OUT_DIR}/CRX/"
	"${FB_OUT_DIR}/${PROJECT_NAME}-${FBSTRING_PLUGIN_VERSION}-${FB_PACKAGE_SUFFIX}.crx"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/linphoneweb.pem"
	"${CMAKE_CURRENT_SOURCE_DIR}/sign/passphrase.txt"
	${PLUGIN_NAME}${FB_CRX_PACKAGE_SUFFIX}
)
###############################################################################
