vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF aug2020
    SHA512 8f79104f7cebab20a739144471337c24fe5078d6d21760d76ec897569609a0a1f25fe2b16782e0561308470cb73a8901c1dd18f7b2741e30c0aa0cee09a30621
    HEAD_REF master
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

if (VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
    set(VS_VERSION "2015")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
    set(VS_VERSION "2017")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
    set(VS_VERSION "2019")
else()
    message(FATAL_ERROR "Unsupported platform toolset.")
endif()

if(VCPKG_TARGET_IS_UWP)
    set(SLN_NAME "Windows10_${VS_VERSION}")
else()
    if(TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
        set(SLN_NAME "Desktop_${VS_VERSION}_Win10")
    else()
        set(SLN_NAME "Desktop_${VS_VERSION}")
    endif()
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_${SLN_NAME}.sln
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
)

file(INSTALL
    ${SOURCE_PATH}/Inc/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK
)

file(INSTALL
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTK.lib
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTK.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTK.lib
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTK.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if(NOT VCPKG_TARGET_IS_UWP)
    set(DXTK_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/directxtk)
    file(MAKE_DIRECTORY ${DXTK_TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/MakeSpriteFont/bin/Release/MakeSpriteFont.exe
        DESTINATION ${DXTK_TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/XWBTool/Bin/Desktop_${VS_VERSION}/${BUILD_ARCH}/Release/XWBTool.exe
        DESTINATION ${DXTK_TOOL_PATH})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
