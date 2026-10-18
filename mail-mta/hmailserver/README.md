# hMailServer Ebuild

Gentoo ebuild for [hMailServer](https://www.hmailserver.com/), a cross-platform
SMTP, IMAP and POP3 mail server.

This ebuild packages the hMailServer 6.x fork maintained by
[Progressive Robot Ltd](https://www.progressiverobot.com/), not the
original 5.x hMailServer project.

## What This Ebuild Does

- Builds the server from the upstream GitLab release tarball
- Installs an OpenRC init script
- Installs `/usr/share/hmailserver/initialconfig.sh`, an interactive script
  that sets the administrator password, creates the database user and
  database, imports the schema, and configures the REST API port
- Supports PostgreSQL (hard dependency, linked at build time) and
  MariaDB/MySQL (optional, loaded at runtime via `dlopen`)

## Dependencies

By default this ebuild pulls in **PostgreSQL** (`dev-db/postgresql`) because
the hMailServer binary links against `libpq.so` at build time. PostgreSQL is
required regardless of which backend you choose in the configuration script.

If you enable the `mariadb` USE flag, the ebuild additionally pulls in
**MariaDB** (`dev-db/mariadb`) as a runtime dependency for the MariaDB/MySQL
backend.

So:

- `USE="-mariadb"` → PostgreSQL only (required), no MariaDB
- `USE="mariadb"` → PostgreSQL (required) + MariaDB (optional backend)

## After Installation

Run the initial configuration script as root:

```
sudo /usr/share/hmailserver/initialconfig.sh
```

It is interactive and must be run from a terminal. It prompts for the
database backend (PostgreSQL or MariaDB/MySQL), database credentials, and
the REST API port.

If you have just installed a database server, initialize it first:

```
PostgreSQL : sudo emerge --config dev-db/postgresql
MariaDB    : sudo emerge --config dev-db/mariadb
```

Then start the service:

```
OpenRC  : sudo rc-service hmailserver start
systemd : sudo systemctl start hmailserver
```

The web UI (REST API) is bound to loopback only:

```
http://127.0.0.1:<port>
```

For remote access, use an SSH tunnel.

## USE Flags

- `mariadb` — pull in `dev-db/mariadb` as a runtime dependency for the
  MariaDB/MySQL backend. The client library is loaded at runtime, not linked.

## Notes

- The hMailServer binary links against `libpq.so` at build time, so
  `dev-db/postgresql` is a hard dependency even if you choose MariaDB as
  your backend.
