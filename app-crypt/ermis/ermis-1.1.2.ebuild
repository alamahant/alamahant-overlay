# ermis-1.1.0.ebuild
# c 2026 Alamahant

EAPI=8
inherit cmake
S="${WORKDIR}/Ermis-1.1.2"

DESCRIPTION="Ermis - Multi-format Steganography Tool (Qt6)"
HOMEPAGE="https://github.com/alamahant/Ermis"
SRC_URI="https://github.com/alamahant/Ermis/archive/refs/tags/v1.1.2.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* amd64 arm64 x86"
IUSE=""

BDEPEND="dev-build/cmake"
RDEPEND="
    dev-qt/qtbase:6[widgets,network,gui,concurrent]
    dev-qt/qtmultimedia:6
    dev-qt/qtwebengine:6[pdfium]
    dev-libs/openssl
    sys-devel/binutils
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
project(Ermis VERSION 1.1.2 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)



find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Network Multimedia Concurrent)
find_package(OpenSSL REQUIRED)
find_package(PkgConfig REQUIRED)


qt_standard_project_setup()

set(PROJECT_SOURCES
    	main.cpp
    	mainwindow.cpp mainwindow.h mainwindow.ui
	passphrasedialog.h passphrasedialog.cpp
        stegengine.h stegengine.cpp
        constants.h constants.cpp
        audiostegengine.h audiostegengine.cpp
        audioplayer.h audioplayer.cpp
        ffmpeghandler.h ffmpeghandler.cpp
        resources.qrc
        helpmenudialog.cpp helpmenudialog.h
        donationdialog.cpp donationdialog.h
        videostegengine.cpp videostegengine.h
        textstegengine.cpp textstegengine.h
        textstegdialog.cpp textstegdialog.h
        textstegdialog.cpp textstegdialog.h textstegengine.cpp textstegengine.h
        icmpstegengine.cpp icmpstegengine.h
        pingdialog.cpp pingdialog.h
        ipfilter.cpp ipfilter.h
        udpstegengine.cpp udpstegengine.h
        ertp_structs.h
        dnsstegengine.cpp dnsstegengine.h
        httpstegengine.cpp httpstegengine.h
        distributedstegengine.cpp distributedstegengine.h
        distributedstegdialog.cpp distributedstegdialog.h
        pdfstegengine.cpp pdfstegengine.h
        pdfstegdialog.cpp pdfstegdialog.h
	elfstegdialog.cpp elfstegdialog.h
	elfstegengine.cpp elfstegengine.h
)

qt_add_executable(Ermis
    WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
)

target_link_libraries(Ermis PRIVATE 
    Qt6::Core
    Qt6::Widgets
    Qt6::Network
    Qt6::Multimedia
    Qt6::Concurrent
    OpenSSL::SSL
    OpenSSL::Crypto

)



set_target_properties(Ermis PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

install(TARGETS Ermis
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
    doins "${S}/io.github.alamahant.Ermis.desktop"

    # Install icons
    insinto /usr/share/icons/hicolor/16x16/apps
    newins "${S}/resources/favicon/favicon-16x16.png" io.github.alamahant.Ermis.png
    
    insinto /usr/share/icons/hicolor/32x32/apps
    newins "${S}/resources/favicon/favicon-32x32.png" io.github.alamahant.Ermis.png
    
    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/resources/favicon/android-chrome-192x192.png" io.github.alamahant.Ermis.png
    
    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/io.github.alamahant.Ermis.png" io.github.alamahant.Ermis.png

elog "=================================================="
elog "ERMIS requires raw socket access for ICMP and"
elog "ping-based steganography features."
elog ""
elog "If these features do not work, run one of these:"
elog ""
elog "  sudo setcap cap_net_raw+ep /usr/bin/Ermis"
elog "  OR"
elog "  sudo chmod u+s /usr/bin/Ermis"
elog ""
elog "Choose setcap (more secure) or suid (traditional)."
elog "=================================================="
    
    

}