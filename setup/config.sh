#!/bin/bash

#setup relative root
if [ -n "$REDMINE_RELATIVE_URL_ROOT" ]; then
  cat >> ${INSTALL_DIR}/config/environment.rb <<EOF

# Setup relative URL
Redmine::Utils::relative_url_root = "/${REDMINE_RELATIVE_URL_ROOT}"
EOF

  #overwrite config.ru
  cat > ${INSTALL_DIR}/config.ru <<EOF
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

map "/${REDMINE_RELATIVE_URL_ROOT}" do
  run RedmineApp::Application
end
EOF
fi


# Email configuration

#smtp user defined?
if [ -n "${SMTP_USER}" ]; then
  SMTP_ENABLED=${SMTP_ENABLED:-true}
  SMTP_AUTHENTICATION=${SMTP_AUTHENTICATION:-:login}
fi

if [ -n "$SMTP_ENABLED" ]; then

  SMTP_HOST=${SMTP_HOST:-smtp.gmail.com}
  SMTP_PORT=${SMTP_PORT:-587}
  SMTP_DOMAIN=${SMTP_DOMAIN:-www.gmail.com}
  SMTP_USER=${SMTP_USER:-}
  SMTP_PASS=${SMTP_PASS:-}
  SMTP_ENABLED=${SMTP_ENABLED:-false}
  SMTP_STARTTLS=${SMTP_STARTTLS:-true}

  #configuration.yml
  cat > ${INSTALL_DIR}/config/configuration.yml <<EOF
# specific configuration options for production environment
# that overrides the default ones
production:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: "$SMTP_HOST"
      port: '$SMTP_PORT'
      domain: "$SMTP_DOMAIN"
      user_name: "$SMTP_USER"
      password: "$SMTP_PASS"
      authentication: $SMTP_AUTHENTICATION
      enable_starttls_auto: $SMTP_STARTTLS
EOF

  echo "Email configured"
fi


#config/initializers/secret_token.rb
rake generate_secret_token
