# selene-1.0.3.ebuild
# c 2025 Alamahant

EAPI=8
inherit cmake
S="${WORKDIR}/Selene-1.0.3"

DESCRIPTION="Selene - Tor P2P Chat & File Sharing (Qt6)"
HOMEPAGE="https://github.com/alamahant/Selene"
SRC_URI="https://github.com/alamahant/Selene/archive/refs/tags/v1.0.3.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="dev-build/cmake"
RDEPEND="
    dev-qt/qtbase:6[widgets,network,gui]
    dev-qt/qtmultimedia:6
    dev-libs/openssl
    net-vpn/tor
    net-misc/curl
"

DEPEND="${RDEPEND}
    dev-build/cmake
"

src_prepare() {
    # Delete the original CMakeLists.txt
    rm -f CMakeLists.txt
    
    # Create new CMakeLists.txt with your content
    cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.19)
project(Selene VERSION 1.0.3 LANGUAGES CXX)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Network Multimedia)
find_package(OpenSSL REQUIRED)

qt_standard_project_setup()

set(PROJECT_SOURCES
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    torconfig.h torconfig.cpp
    logger.h logger.cpp
    torprocess.h torprocess.cpp
    networkmanager.h networkmanager.cpp
    peerstate.h
    contact.h
    contactmanager.h contactmanager.cpp
    contactcardwidget.h contactcardwidget.cpp
    contactlistwidget.h contactlistwidget.cpp
    chatmanager.h chatmanager.cpp
    messagebubblewidget.h messagebubblewidget.cpp
    constants.h
    emojipickerwidget.h emojipickerwidget.cpp
    resources.qrc
    simplehttpfileserver.h simplehttpfileserver.cpp
    constants.cpp
    chatmessage.h chatmessage.cpp
    chatsession.h chatsession.cpp
    logviewerdialog.h logviewerdialog.cpp
    helpmenudialog.cpp helpmenudialog.h
    securitymanager.cpp securitymanager.h
    Notification.h
    donationdialog.cpp donationdialog.h
    httpclientdialog.h httpclientdialog.cpp
    bridgemanagerdialog.h bridgemanagerdialog.cpp
)


# Explicitly process the resource file
qt_add_resources(Selene_RESOURCES resources.qrc)

qt_add_executable(Selene
    WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
    ${Selene_RESOURCES}
)

target_link_libraries(Selene PRIVATE 
    Qt6::Core
    Qt6::Widgets
    Qt6::Network
    Qt6::Multimedia
    OpenSSL::Crypto
)

set_target_properties(Selene PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

install(TARGETS Selene
    BUNDLE  DESTINATION .
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
    doins "${S}/Selene.desktop"

    # Install icons - CORRECT METHOD 1: using insinto + doins
    insinto /usr/share/icons/hicolor/16x16/apps
    newins "${S}/favicons/16x16.png" io.github.alamahant.Selene.png
    
    insinto /usr/share/icons/hicolor/32x32/apps
    newins "${S}/favicons/32x32.png" io.github.alamahant.Selene.png
    
    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/favicons/192x192.png" io.github.alamahant.Selene.png
    
    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/favicons/512x512.png" io.github.alamahant.Selene.png

}
