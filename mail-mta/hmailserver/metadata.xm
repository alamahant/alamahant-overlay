<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
  <use>
    <flag name="mariadb">Additionally pull in dev-db/mariadb as a runtime dependency for the MariaDB/MySQL backend. The client library is loaded at runtime via dlopen, not linked at build time. Note that dev-db/postgresql is pulled in unconditionally because the hMailServer binary links against libpq.so at build time, regardless of which backend you choose.</flag>
  </use>
</pkgmetadata>