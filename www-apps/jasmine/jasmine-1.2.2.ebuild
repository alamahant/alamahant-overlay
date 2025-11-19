# Copyright 2025 Alamahant
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
S="${WORKDIR}/Jasmine-1.2.2"

DESCRIPTION="A Qt6-based website launcher and session manager"
HOMEPAGE="https://github.com/alamahant/Jasmine"
SRC_URI="https://github.com/alamahant/Jasmine/archive/refs/tags/v1.2.2.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
BDEPEND="dev-build/cmake"
DEPEND="
dev-qt/qtbase:6[gui,widgets]
dev-qt/qtwebengine:6[widgets,pulseaudio]
"
RDEPEND="${DEPEND}"


src_configure() {
    local mycmakeargs=(
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install
 # Desktop file (renamed source path as requested)
    insinto /usr/share/applications
    doins "${S}/Jasmine.desktop"

    # Icons
    insinto /usr/share/icons/hicolor/512x512/apps
    doins "${S}/io.github.alamahant.Jasmine.png"

    insinto /usr/share/icons/hicolor/16x16/apps
    doins "${S}/resources/favicon/16x16/io.github.alamahant.Jasmine.png"

    insinto /usr/share/icons/hicolor/32x32/apps
    doins "${S}/resources/favicon/32x32/io.github.alamahant.Jasmine.png"

    insinto /usr/share/icons/hicolor/192x192/apps
    doins "${S}/resources/favicon/192x192/io.github.alamahant.Jasmine.png"
}
