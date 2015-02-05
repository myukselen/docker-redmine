#!/bin/bash

PLUGINS_SRC_DIR=${DATA_DIR}/plugins
PLUGINS_DEST_DIR=${INSTALL_DIR}/plugins

remove_plugin() {
  echo "removing plugin $*"
  bundle exec rake redmine:plugins:migrate NAME=$1 VERSION=0 RAILS_ENV=production
  rm -rf "${PLUGINS_DEST_DIR}/$1"
  echo "removed plugin $*"
}

install_plugin() {
  echo "installing plugin $1"
  cp -a $PLUGINS_SRC_DIR/$1 $PLUGINS_DEST_DIR
  bundle exec rake redmine:plugins:migrate NAME=$1 RAILS_ENV=production
  echo "installed plugin $1"
}

#check for removed plugins
for plugin_path in $(find ${PLUGINS_DEST_DIR} -maxdepth 1 -mindepth 1 -type d)
do
  plugin=$(basename ${plugin_path})
  if [ ! -d ${PLUGINS_SRC_DIR}/$plugin ]; then
    remove_plugin "$plugin"
  fi
done


#check for installed plugins
for plugin_path in $(find ${PLUGINS_SRC_DIR} -maxdepth 1 -mindepth 1 -type d)
do
  plugin=$(basename ${plugin_path})
  if [ ! -d ${PLUGINS_DEST_DIR}/$plugin ]; then
    install_plugin "$plugin"
  fi
done
