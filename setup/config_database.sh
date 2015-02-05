#!/bin/bash

# prepare database connection based on container link
cat > ${INSTALL_DIR}/config/database.yml <<EOF
production:
  adapter: "postgresql"
  encoding: "unicode"
  #reconnect: false
  database: "${POSTGRESQL_ENV_DB_NAME}"
  host: "${POSTGRESQL_PORT_5432_TCP_ADDR}"
  port: ${POSTGRESQL_PORT_5432_TCP_PORT}
  username: "${POSTGRESQL_ENV_DB_USER}"
  password: "${POSTGRESQL_ENV_DB_PASS}"
  pool: 3
EOF
