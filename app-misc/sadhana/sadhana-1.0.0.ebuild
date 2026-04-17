# sadhana-0.1.ebuild
# c 2026 Alamahant

EAPI=8
inherit cmake
S="${WORKDIR}/Sadhana-1.0.0"

DESCRIPTION="Sadhana - Buddhist meditation and practice assistant (Qt6)"
HOMEPAGE="https://github.com/alamahant/Sadhana"
SRC_URI="https://github.com/alamahant/Sadhana/archive/refs/tags/v1.0.0.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="dev-build/cmake"
RDEPEND="
    dev-qt/qtbase:6[widgets,gui]
    dev-qt/qtmultimedia:6
    dev-qt/qtwebengine:6[widgets,opengl]  
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
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(Sadhana LANGUAGES CXX)

option(FLATPAK_BUILD "Building for Flatpak" OFF)
if(FLATPAK_BUILD)
    add_compile_definitions(FLATPAK_BUILD)
    message(STATUS "Building for Flatpak")
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Multimedia PdfWidgets)

qt_add_executable(Sadhana
    MANUAL_FINALIZATION
    main.cpp
    mainwindow.cpp mainwindow.h mainwindow.ui
    deitymodule.cpp deitymodule.h
    gridview.cpp gridview.h
    modulemanager.cpp modulemanager.h
    modulesquare.cpp modulesquare.h
    pujaview.cpp pujaview.h
    imagefullscreendialog.cpp imagefullscreendialog.h
    custommodule.h customodule.cpp
    stage.cpp stage.h
    createmoduledialog.cpp createmoduledialog.h
    readerdialog.cpp readerdialog.h
    tibetancalendar.cpp tibetancalendar.h
    tibetancalendardialog.cpp tibetancalendardialog.h
    journalmanager.cpp journalmanager.h
    journaldialog.cpp journaldialog.h
    constants.cpp constants.h
    donationdialog.cpp donationdialog.h
    resources.qrc
)

target_link_libraries(Sadhana
    PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Multimedia
        Qt6::PdfWidgets
)

if(FLATPAK_BUILD)
    add_custom_command(TARGET Sadhana POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/images"
            "$<TARGET_FILE_DIR:Sadhana>/images"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/files"
            "$<TARGET_FILE_DIR:Sadhana>/files"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/modules"
            "$<TARGET_FILE_DIR:Sadhana>/modules"
        COMMENT "Copying images modules and files to build directory"
    )
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/files"
            DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/images"
            DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/modules"
            DESTINATION ${CMAKE_INSTALL_BINDIR})
else()
    add_custom_command(TARGET Sadhana POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/images"
            "$<TARGET_FILE_DIR:Sadhana>/images"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/files"
            "$<TARGET_FILE_DIR:Sadhana>/files"
        COMMENT "Copying images and files to build directory (Development)"
    )
endif()

include(GNUInstallDirs)
install(TARGETS Sadhana
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(FLATPAK_BUILD)
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/io.github.alamahant.Sadhana.desktop"
            DESTINATION "share/applications")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/io.github.alamahant.Sadhana.metainfo.xml"
            DESTINATION "share/metainfo")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/io.github.alamahant.Sadhana.png"
            DESTINATION "share/icons/hicolor/512x512/apps"
            RENAME "io.github.alamahant.Sadhana.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon_io/android-chrome-192x192.png"
            DESTINATION "share/icons/hicolor/192x192/apps"
            RENAME "io.github.alamahant.Sadhana.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon_io/favicon-16x16.png"
            DESTINATION "share/icons/hicolor/16x16/apps"
            RENAME "io.github.alamahant.Sadhana.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon_io/favicon-32x32.png"
            DESTINATION "share/icons/hicolor/32x32/apps"
            RENAME "io.github.alamahant.Sadhana.png")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/favicon_io/apple-touch-icon.png"
            DESTINATION "share/icons/hicolor/180x180/apps"
            RENAME "io.github.alamahant.Sadhana.png")
endif()

qt_finalize_executable(Sadhana)
EOF

    cmake_src_prepare
}

src_configure() {
    local mycmakeargs=(
        -DFLATPAK_BUILD=ON
    )
    cmake_src_configure
}

src_install() {
    cmake_src_install

    # Desktop file
    insinto /usr/share/applications
    doins "${S}/io.github.alamahant.Sadhana.desktop"

    # Install icons
    insinto /usr/share/icons/hicolor/16x16/apps
    newins "${S}/favicon_io/favicon-16x16.png" io.github.alamahant.Sadhana.png
    
    insinto /usr/share/icons/hicolor/32x32/apps
    newins "${S}/favicon_io/favicon-32x32.png" io.github.alamahant.Sadhana.png
    
    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/favicon_io/android-chrome-192x192.png" io.github.alamahant.Sadhana.png
    
    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/io.github.alamahant.Sadhana.png" io.github.alamahant.Sadhana.png

    # Copy data directories
    dodir /usr/share/${PN}/images
    cp -r "${S}/images"/* "${D}/usr/share/${PN}/images/" || die "Failed to copy images"
    
    dodir /usr/share/${PN}/files
    cp -r "${S}/files"/* "${D}/usr/share/${PN}/files/" || die "Failed to copy files"
    
    dodir /usr/share/${PN}/modules
    cp -r "${S}/modules"/* "${D}/usr/share/${PN}/modules/" || die "Failed to copy modules"
}