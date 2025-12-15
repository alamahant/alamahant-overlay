# Copyright 2025 Alamahant
EAPI=8

inherit cmake
S="${WORKDIR}/BinauralPlayer-1.1.0"

DESCRIPTION="BinauralPlayer - A binaural and isochronic tone generator and full-featured audio player"
HOMEPAGE="https://github.com/alamahant/BinauralPlayer"
SRC_URI="https://github.com/alamahant/BinauralPlayer/archive/refs/tags/v1.1.0.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-build/cmake"
DEPEND="
    dev-qt/qtbase:6[gui,widgets,network]
    dev-qt/qtmultimedia:6
"
RDEPEND="${DEPEND}"

src_prepare() {
    # Delete the original CMakeLists.txt
    rm -f "${S}/CMakeLists.txt"
    
    # Create new Qt6-only CMakeLists.txt

    cat > "${S}/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.19)
project(BinauralPlayer VERSION 1.1.0 LANGUAGES CXX)

# Qt6 auto features
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)


# Find Qt6 components
find_package(Qt6 6.5 REQUIRED COMPONENTS 
    Core
    Widgets
    Multimedia
)

qt_standard_project_setup()

set(PROJECT_SOURCES
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    binauralengine.h 
    binauralengine.cpp
    dynamicengine.h
    dynamicengine.cpp
    constants.h 
    constants.cpp
    helpmenudialog.h 
    helpmenudialog.cpp 
    donationdialog.h 
    donationdialog.cpp
    ambientplayer.h 
    ambientplayer.cpp
    ambientplayerdialog.h 
    ambientplayerdialog.cpp
    resources.qrc
)

qt_add_executable(BinauralPlayer
    WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
)

target_link_libraries(BinauralPlayer PRIVATE 
    Qt6::Core
    Qt6::Widgets
    Qt6::Multimedia
)

set_target_properties(BinauralPlayer PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

# Install the application
install(TARGETS BinauralPlayer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Conditionally install desktop file and icons for Gentoo

    # Install desktop file
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/BinauralPlayer.desktop"
            DESTINATION "share/applications")
    
    # Install icons
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon/android-chrome-192x192.png"
            DESTINATION "share/icons/hicolor/192x192/apps"
            RENAME "io.github.alamahant.BinauralPlayer.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon/android-chrome-512x512.png"
            DESTINATION "share/icons/hicolor/512x512/apps"
            RENAME "io.github.alamahant.BinauralPlayer.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon/favicon-16x16.png"
            DESTINATION "share/icons/hicolor/16x16/apps"
            RENAME "io.github.alamahant.BinauralPlayer.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon/favicon-32x32.png"
            DESTINATION "share/icons/hicolor/32x32/apps"
            RENAME "io.github.alamahant.BinauralPlayer.png")

EOF

    cmake_src_prepare
}

src_configure() {
    local mycmakeargs=(

        -DCMAKE_BUILD_TYPE=Release
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
    doins "${S}/BinauralPlayer.desktop"

    # Install icons from the favicon directory
    insinto /usr/share/icons/hicolor/16x16/apps
    newins "${S}/favicon/favicon-16x16.png" io.github.alamahant.BinauralPlayer.png

    insinto /usr/share/icons/hicolor/32x32/apps
    newins "${S}/favicon/favicon-32x32.png" io.github.alamahant.BinauralPlayer.png

    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/favicon/android-chrome-192x192.png" io.github.alamahant.BinauralPlayer.png

    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/favicon/android-chrome-512x512.png" io.github.alamahant.BinauralPlayer.png
}