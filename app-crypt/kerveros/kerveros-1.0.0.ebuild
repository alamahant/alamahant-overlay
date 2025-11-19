# Copyright 2025 Dharma
EAPI=8

inherit cmake
S="${WORKDIR}/Kerveros-1.0.0"

DESCRIPTION="Kerveros - A 2FA / TOTP code manager written in Qt"
HOMEPAGE="https://github.com/alamahant/Kerveros"
SRC_URI="https://github.com/alamahant/Kerveros/archive/refs/tags/v1.0.0.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

# Build-time and runtime dependencies
BDEPEND="dev-build/cmake"
DEPEND="
    dev-qt/qtbase:6[widgets,gui,network]
    media-gfx/zbar
"

RDEPEND="${DEPEND}"

# Use system libraries, disable Flathub-specific builds

src_configure() {
    cmake_src_configure ${cmake_args}
}

src_install() {
    cmake_src_install

    # Install desktop file
    insinto /usr/share/applications
    newins "${S}/Kerveros.desktop" Kerveros.desktop

    # Install PNG icons
    insinto /usr/share/icons/hicolor/16x16/apps
    newins "${S}/favicon_io/favicon-16x16.png" io.github.alamahant.Kerveros.png

    insinto /usr/share/icons/hicolor/32x32/apps
    newins "${S}/favicon_io/favicon-32x32.png" io.github.alamahant.Kerveros.png

    insinto /usr/share/icons/hicolor/192x192/apps
    newins "${S}/favicon_io/android-chrome-192x192.png" io.github.alamahant.Kerveros.png

    insinto /usr/share/icons/hicolor/512x512/apps
    newins "${S}/favicon_io/android-chrome-512x512.png" io.github.alamahant.Kerveros.png
}
