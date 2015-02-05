#!/bin/bash

#store the script dir, because config.sh is here
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#workdir is installation directory
cd ${INSTALL_DIR}

#configure database connection settings
bash $SCRIPT_DIR/config_database.sh

#main configuration done?
if [ -e "CONFIG_DONE" ]; then
  echo "Skipping Configuration"
else
  bash $SCRIPT_DIR/config.sh
  touch CONFIG_DONE
  echo "Configuration done"
fi

#handle plugin install and removal
if [ -d ${DATA_DIR}/plugins ]; then
  bash $SCRIPT_DIR/config_plugins.sh
fi

# any database changes?
RAILS_ENV=production rake db:migrate

# clean up for crashes
rake tmp:cache:clear
rake tmp:sessions:clear

#left as reference, use for troubleshooting only
#run webrick server
#ruby script/rails server webrick -e production


#default to port 3000 on all interfaces
PUMA_BIND_URI=${PUMA_BIND_URI:-tcp://0.0.0.0:3000}
#run puma with maximum 2 threads if not configured
PUMA_THREADS=${PUMA_THREADS:-0:2}

#run puma
exec puma -e $RAILS_ENV -b "$PUMA_BIND_URI" -t $PUMA_THREADS --prune-bundler
