# Copyright 2025 Alamahant

EAPI=8
inherit git-r3 cmake

DESCRIPTION="Asteria - Astrology app using Swiss Ephemeris and AI interpretation of charts"
HOMEPAGE="https://github.com/alamahant/Asteria"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-build/cmake"
DEPEND="
    dev-qt/qtbase:6[widgets,gui,network,opengl]
    dev-qt/qtsvg:6
    dev-qt/qtdeclarative:6
    dev-qt/qtpositioning:6
    dev-qt/qtlocation:6
    dev-qt/qtcharts:6
    dev-qt/qtopengl
"

RDEPEND="${DEPEND}"

# Live git repositories
EGIT_REPO_URI="https://github.com/alamahant/Asteria.git"
EGIT_BRANCH="main"

src_unpack() {
    # Clone main Asteria repository
    git-r3_src_unpack
    
    # Clone Swiss Ephemeris to a temporary location
    local EGIT_REPO_URI="https://github.com/aloistr/swisseph.git"
    local EGIT_COMMIT="c353e6f813c825fcb7c4c005e4ebfdd2cf31c21b"
    local EGIT_BRANCH=""
    local swisseph_dir="${WORKDIR}/swisseph-temp"
    
    git-r3_peek_remote_ref 
    git-r3_fetch
    git-r3_checkout "" "${swisseph_dir}"
}

src_prepare() {
    # Move Swiss Ephemeris to the expected location in the source tree
    einfo "Setting up Swiss Ephemeris..."
    if [[ -d "${WORKDIR}/swisseph-temp" ]]; then
        mv "${WORKDIR}/swisseph-temp" "${S}/swisseph_src" || die "Failed to setup Swiss Ephemeris"
    else
        die "Swiss Ephemeris source not found in ${WORKDIR}/swisseph-temp"
    fi

    # Delete the original CMakeLists.txt
    rm -f CMakeLists.txt
    
    # Create new CMakeLists.txt with Qt6-only format
    cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.19)
project(Asteria VERSION 0.1 LANGUAGES CXX)

# Ensure resource compilation
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)


# Option to build for Flathub
option(GENTOO_BUILD "Build for Gentoo" OFF)
# Define GENTOO_BUILD for conditional compilation
if(GENTOO_BUILD)
    add_definitions(-DGENTOO_BUILD)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS 
    Core 
    Widgets 
    Network 
    Svg 
    QuickWidgets 
    Positioning 
    Location 
    Charts
    OpenGL
    OpenGLWidgets
    Quick
    Qml
)
find_package(PkgConfig REQUIRED)
pkg_check_modules(ZBAR REQUIRED zbar)

# Build Swiss Ephemeris from source
set(SWISSEPH_SRC_DIR "${CMAKE_SOURCE_DIR}/swisseph_src")

# Check if source directory exists
if(NOT EXISTS ${SWISSEPH_SRC_DIR})
    message(FATAL_ERROR "Swiss Ephemeris source directory not found at ${SWISSEPH_SRC_DIR}")
endif()

# Build Swiss Ephemeris
execute_process(
    COMMAND make
    WORKING_DIRECTORY ${SWISSEPH_SRC_DIR}
    RESULT_VARIABLE MAKE_RESULT
)

if(NOT MAKE_RESULT EQUAL "0")
    message(FATAL_ERROR "Failed to build Swiss Ephemeris")
endif()

# Set paths for Swiss Ephemeris
set(SWISSEPH_INCLUDE_DIR "${SWISSEPH_SRC_DIR}")
set(SWISSEPH_LIBRARY "${SWISSEPH_SRC_DIR}/libswe.a")

# Create imported target for Swiss Ephemeris
add_library(sweph STATIC IMPORTED)
set_target_properties(sweph PROPERTIES
    IMPORTED_LOCATION ${SWISSEPH_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${SWISSEPH_INCLUDE_DIR}
)

qt_standard_project_setup()

set(PROJECT_SOURCES
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    chartcalculator.h chartcalculator.cpp
    chartdatamanager.h chartdatamanager.cpp
    chartrenderer.h chartrenderer.cpp
    mistralapi.h mistralapi.cpp
    chartwidget.h chartwidget.cpp
    aspectarianwidget.h aspectarianwidget.cpp
    elementmodalitywidget.h elementmodalitywidget.cpp
    planetlistwidget.h planetlistwidget.cpp
    symbolsdialog.h symbolsdialog.cpp
    osmmapdialog.h osmmapdialog.cpp
    Globals.h
    aspectsettingsdialog.h aspectsettingsdialog.cpp
    transitsearchdialog.h transitsearchdialog.cpp
    Globals.cpp
    donationdialog.h donationdialog.cpp
    resources.qrc
)

qt_add_executable(Asteria
    WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
)

target_link_libraries(Asteria PRIVATE 
    Qt6::Core
    Qt6::Widgets
    Qt6::Network
    Qt6::Svg
    Qt6::QuickWidgets
    Qt6::Location
    Qt6::Positioning
    Qt6::Charts
    Qt6::OpenGL
    Qt6::OpenGLWidgets
    Qt6::Quick
    Qt6::Qml
    sweph
)

target_compile_definitions(Asteria PRIVATE SWISSEPH_DATA_DIR="/usr/share/Asteria/ephemeris")

set_target_properties(Asteria PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

# Install ephemeris files
install(DIRECTORY ${SWISSEPH_SRC_DIR}/ephe/
        DESTINATION share/Asteria/ephemeris
        FILES_MATCHING PATTERN "*.se1")

# Install the application
install(TARGETS Asteria
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# Install desktop file and metainfo
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/Asteria.desktop"
        DESTINATION "share/applications")
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/io.github.alamahant.Asteria.metainfo.xml"
        DESTINATION "share/metainfo")

# Install icons
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/icons/asteria-icon-192.png"
        DESTINATION "share/icons/hicolor/192x192/apps"
        RENAME "io.github.alamahant.Asteria.png")
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/icons/asteria-icon-256.png"
        DESTINATION "share/icons/hicolor/256x256/apps"
        RENAME "io.github.alamahant.Asteria.png")
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/icons/asteria-icon-512.png"
        DESTINATION "share/icons/hicolor/512x512/apps"
        RENAME "io.github.alamahant.Asteria.png")
EOF

    cmake_src_prepare
}

src_configure() {
    local mycmakeargs=(
        -DGENTOO_BUILD=ON
    )
    cmake_src_configure "${mycmakeargs[@]}"
}

src_compile() {
    cmake_build
}

src_install() {
    cmake_src_install

    # Install desktop file
    insinto /usr/share/applications
    doins "${S}/Asteria.desktop"

    # Install icons
    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/icons/asteria-icon-192.png" io.github.alamahant.Asteria.png
    insinto /usr/share/icons/hicolor/256x256/apps
    newins "${S}/icons/asteria-icon-256.png" io.github.alamahant.Asteria.png
    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/icons/asteria-icon-512.png" io.github.alamahant.Asteria.png
}
