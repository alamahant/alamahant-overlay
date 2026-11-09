EAPI=8

inherit cmake

DESCRIPTION="Cross-platform SMTP, IMAP and POP3 mail server"
HOMEPAGE="https://www.progressiverobot.com/hmailserver-services/"

SRC_URI="https://gitlab.com/hmailserver/hmailserver/-/archive/v${PV}/hmailserver-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="mariadb"

RDEPEND="
	dev-libs/openssl:=
	dev-libs/boost:=
	sys-libs/zlib:=
	dev-db/postgresql
	net-nds/openldap
	dev-libs/cyrus-sasl
	mariadb? ( dev-db/mariadb )
"

BDEPEND="
	dev-build/cmake
"

DEPEND="${RDEPEND}"



S="${WORKDIR}/hmailserver-v${PV}"
CMAKE_USE_DIR="${S}/hmailserver/source/Server"

src_prepare() {
	# Use shared Gentoo Boost libraries.
	sed -i \
		's/set(Boost_USE_STATIC_LIBS ON)/set(Boost_USE_STATIC_LIBS OFF)/' \
		"${CMAKE_USE_DIR}/CMakeLists.txt" ||
		die "Failed to patch Boost linkage"

	# Remove upstream's unconditional systemd installation rule.
	sed -i \
		'/install(FILES .*platform\/packaging\/hmailserver\.service/,+1d' \
		"${CMAKE_USE_DIR}/CMakeLists.txt" ||
		die "Failed to remove upstream systemd install rule"

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DHM_BOOST_STATIC=OFF
	)

	cmake_src_configure
}

src_install() {

	cmake_src_install

	# Systemd unit
	insinto /usr/lib/systemd/system
	doins "${FILESDIR}/hmailserver.service"

	# Persistent directories from [Directories] in hMailServer.ini
	keepdir /var/lib/hmailserver
	keepdir /var/lib/hmailserver/temp
	keepdir /var/lib/hmailserver/events
	keepdir /var/lib/hmailserver/database
	keepdir /var/log/hmailserver

	# OpenRC init script
	newinitd "${FILESDIR}/hmailserver.initd" hmailserver

	# Initial configuration script
	exeinto /usr/share/hmailserver
	doexe "${FILESDIR}/initialconfig.sh"

	# Remove upstream live-update units; version management is Portage's job
	rm -f "${ED}/usr/lib/systemd/system/hmailserver-update.path"
	rm -f "${ED}/usr/lib/systemd/system/hmailserver-update.service"

}

pkg_postinst() {
	einfo "hMailServer has been installed."
	einfo ""
	einfo "Before starting the service, you must run the initial"
	einfo "configuration script as root:"
	einfo ""
	einfo "    sudo /usr/share/hmailserver/initialconfig.sh"
	einfo ""
	einfo "This script is interactive and must be run from a terminal."
	einfo "It will set the administrator password, create the database"
	einfo "user and database, and import the schema."
	einfo ""
	einfo "If you have just installed a database server, initialize it"
	einfo "first:"
	einfo ""
	einfo "    PostgreSQL : sudo emerge --config dev-db/postgresql"
	einfo "    MariaDB    : sudo emerge --config dev-db/mariadb"
	einfo ""
}
