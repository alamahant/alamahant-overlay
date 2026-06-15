# ichingdiviner-0.1.ebuild
# c 2026 Alamahant

EAPI=8
inherit cmake
S="${WORKDIR}/IChingDiviner-1.0.4"

DESCRIPTION="IChingDiviner - I Ching divination and AI interpretation tool (Qt6)"
HOMEPAGE="https://github.com/alamahant/IChingDiviner"
SRC_URI="https://github.com/alamahant/IChingDiviner/archive/refs/tags/v1.0.4.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="dev-build/cmake"
RDEPEND="
    dev-qt/qtbase:6[widgets,network,gui]
    dev-qt/qtsvg:6
    dev-qt/qtmultimedia:6
"

DEPEND="${RDEPEND}
    dev-build/cmake
"

src_prepare() {
    # Delete the original CMakeLists.txt
    rm -f CMakeLists.txt
    
    # Create new CMakeLists.txt with your content
    cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.16)
project(IChingDiviner VERSION 1.0.4 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Network Svg Multimedia)

qt_standard_project_setup()

set(PROJECT_SOURCES
    main.cpp
    mainwindow.cpp mainwindow.h mainwindow.ui
    iching.h iching.cpp
    constants.cpp constants.h
    aimanager.cpp aimanager.h
    modelselectordialog.cpp modelselectordialog.h
    model.h
    donationdialog.cpp donationdialog.h
    helpmenudialog.cpp helpmenudialog.h
    resources.qrc
journalcalendar.cpp journalcalendar.h journaldialog.cpp journaldialog.h journalmanager.cpp journalmanager.h socialshare.cpp socialshare.h socialsharedialog.cpp socialsharedialog.h
        hexagrambrowserdialog.cpp hexagrambrowserdialog.h
)

qt_add_executable(IChingDiviner
    WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
)

target_link_libraries(IChingDiviner PRIVATE 
    Qt6::Core
    Qt6::Widgets
    Qt6::Network
    Qt6::Svg
    Qt6::Multimedia
)

set_target_properties(IChingDiviner PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

install(TARGETS IChingDiviner
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)


EOF

    cmake_src_prepare
}

src_configure() {
    local mycmakeargs=(

    )
    cmake_src_configure
}

src_install() {
    cmake_src_install

    # Desktop file
    insinto /usr/share/applications
    doins "${S}/io.github.alamahant.IChingDiviner.desktop"

    # Install icons
    insinto /usr/share/icons/hicolor/16x16/apps
    newins "${S}/files/favicon-16x16.png" io.github.alamahant.IChingDiviner.png
    
    insinto /usr/share/icons/hicolor/32x32/apps
    newins "${S}/files/favicon-32x32.png" io.github.alamahant.IChingDiviner.png
    
    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/files/android-chrome-192x192.png" io.github.alamahant.IChingDiviner.png
    
    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/io.github.alamahant.IChingDiviner.png" io.github.alamahant.IChingDiviner.png

    # Install font
    insinto /usr/share/${PN}/fonts
    doins "${S}/fonts/Noto_Serif_TC/static/NotoSerifTC-Black.ttf"
}