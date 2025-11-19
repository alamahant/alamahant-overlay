# Copyright 2025 Alamahant
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
S="${WORKDIR}/TarotCaster-1.2.2"

DESCRIPTION="TarotCaster - Tarot reading application with AI interpretation"
HOMEPAGE="https://github.com/alamahant/TarotCaster"
SRC_URI="https://github.com/alamahant/TarotCaster/archive/refs/tags/v1.2.2.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-build/cmake"
RDEPEND="
	dev-qt/qtbase:6[widgets,gui,network]
	dev-qt/qtopengl
"

DEPEND="${RDEPEND}"


src_prepare() {
	# Delete the original CMakeLists.txt
	rm -f CMakeLists.txt

	# Create new CMakeLists.txt with Qt6-only format
	cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.19)
project(TarotCaster VERSION 1.2.2 LANGUAGES CXX)

# Ensure resource compilation
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

option(GENTOO_BUILD "Build for Gentoo" OFF)
if(GENTOO_BUILD)
    add_compile_definitions(GENTOO_BUILD)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Network OpenGLWidgets)

qt_standard_project_setup()

set(PROJECT_SOURCES
    main.cpp
    mainwindow.cpp mainwindow.h
    cardloader.h cardloader.cpp
    tarotscene.h tarotscene.cpp
    tarotcarditem.h tarotcarditem.cpp
    cardmeaning.h cardmeaning.cpp
    meaningdisplay.h meaningdisplay.cpp
    dockcontrols.h dockcontrols.cpp
    mistralapi.h mistralapi.cpp
    resources.qrc
    helpdialog.h helpdialog.cpp
    customspreaddesigner.h customspreaddesigner.cpp
    tarotorderdialog.h tarotorderdialog.cpp
    Globals.h Globals.cpp
    donationdialog.cpp donationdialog.h
)

# Explicitly process the resource file
qt_add_resources(TarotCaster_RESOURCES resources.qrc)



qt_add_executable(TarotCaster
    WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
    ${TarotCaster_RESOURCES}
)

target_link_libraries(TarotCaster PRIVATE 
    Qt6::Core
    Qt6::Widgets
    Qt6::Network
    Qt6::OpenGLWidgets
)

set_target_properties(TarotCaster PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

install(TARGETS TarotCaster
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)


EOF

	cmake_src_prepare
}

src_configure() {
local mycmakeargs=(
    -DGENTOO_BUILD=ON
    )
    cmake_src_configure "${mycmakeargs[@]}"

}

src_install() {
	cmake_src_install

	# Install desktop file
	insinto /usr/share/applications
	doins "${S}/TarotCaster.desktop"


	# Install icon
	insinto /usr/share/icons/hicolor/512x512/apps
	doins "${S}/io.github.alamahant.TarotCaster.png"

	# Install decks directory structure
	insinto /usr/share/tarotcaster
	doins -r "${S}/decks"

	# Install card meanings
	insinto /usr/share/tarotcaster
	doins "${S}/resources/card_meanings.json"
}
