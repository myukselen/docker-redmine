FROM ruby:2.1.5

MAINTAINER Murat Yukselen <muratyukselen@yahoo.com>

ENV REDMINE_VERSION=2.6.1 \
  INSTALL_DIR=/redmine \
  DATA_DIR=/data \
  LOG_DIR=/var/log/redmine \
  RAILS_ENV=production

VOLUME ["/var/log/redmine", "/data"]


#extract redmine release
#setup folder links to volumes
#store version info to image
ADD setup/redmine-${REDMINE_VERSION}.tar.gz /tmp
RUN mv /tmp/redmine-${REDMINE_VERSION} ${INSTALL_DIR} \
  && mkdir -p ${DATA_DIR}/files \
  && rm -rf ${INSTALL_DIR}/files \
  && ln -s ${DATA_DIR}/files ${INSTALL_DIR}/files \
  && rm -rf ${INSTALL_DIR}/log \
  && ln -s ${LOG_DIR} ${INSTALL_DIR}/log \
  && echo ${REDMINE_VERSION} > ${INSTALL_DIR}/VERSION

#install gems
# append postgresql and puma gems to the end of Gemfile first
WORKDIR ${INSTALL_DIR}
RUN grep 'gem "pg"' Gemfile | awk '{gsub(/^[ \t]+|[ \t]+$/,""); print;}' >> Gemfile \
  && echo 'gem "puma"' >> Gemfile \
  && bundle install --without development test mysql sqlite

#copy helper scripts
COPY setup/*.sh /opt/
RUN chmod u+x /opt/*.sh

# port for webrick or puma server
EXPOSE 3000

# default command
CMD ["bash", "/opt/run.sh"]
