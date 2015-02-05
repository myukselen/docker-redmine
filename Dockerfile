FROM ruby:2.1.5

MAINTAINER Murat Yukselen <muratyukselen@yahoo.com>

ENV REDMINE_VERSION=2.6.1
ENV INSTALL_DIR=/redmine
ENV DATA_DIR=/data
ENV LOG_DIR=/var/log/redmine
ENV RAILS_ENV=production

VOLUME ["/var/log/redmine"]
VOLUME ["/data"]

#extract redmine release
ADD setup/redmine-${REDMINE_VERSION}.tar.gz /tmp
RUN mv /tmp/redmine-${REDMINE_VERSION} /redmine

#setup folder links to volumes
WORKDIR ${INSTALL_DIR}
RUN mkdir -p ${DATA_DIR}/files \
  && rm -rf files \
  && ln -s ${DATA_DIR}/files files \
  && rm -rf log \
  && ln -s ${LOG_DIR} log

#install gems
# append postgresql and puma gems to the end of Gemfile first
RUN grep 'gem "pg"' Gemfile | awk '{gsub(/^[ \t]+|[ \t]+$/,""); print;}' >> Gemfile \
  && echo 'gem "puma"' >> Gemfile \
  && bundle install --without development test mysql sqlite

#store version info to image
RUN echo ${REDMINE_VERSION} > VERSION

#copy helper scripts
COPY setup/*.sh /opt/
RUN chmod u+x /opt/*.sh

# port for webrick or puma server
EXPOSE 3000

# default command
CMD ["bash", "/opt/run.sh"]
