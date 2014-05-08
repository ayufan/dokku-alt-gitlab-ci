FROM ubuntu:trusty
MAINTAINER Kamil Trzciński <ayufan@ayufan.eu>

RUN apt-get update -y
RUN apt-get install -y sudo build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate git-core ruby2.0-dev bundler mysql-client libmysqlclient-dev openssh-server ca-certificates supervisor

RUN adduser --disabled-login --gecos 'GitLab CI' gitlab_ci

USER gitlab_ci
WORKDIR /home/gitlab_ci
ENV HOME /home/gitlab_ci

RUN git clone https://github.com/gitlabhq/gitlab-ci.git gitlab-ci -b v5.0.0 

RUN mkdir -p gitlab-ci/log/ gitlab-ci/tmp/pids/ gitlab-ci/tmp/sockets/ && \
	chmod -R u+rwX gitlab-ci/log/ && \
	chmod -R u+rwX gitlab-ci/tmp/ && \
	chmod -R u+rwX gitlab-ci/tmp/pids/ && \
	chmod -R u+rwX gitlab-ci/tmp/sockets/

RUN git config --global user.name "GitLab CI" && \
	git config --global user.email "gitlab-ci@ayufan.eu" && \
	git config --global core.autocrlf input

WORKDIR /home/gitlab_ci/gitlab-ci
RUN bundle install --deployment --without development test postgres
RUN bundle exec rake assets:precompile RAILS_ENV=production

# add configs at the end
USER root
ADD gitlab-ci/ /home/gitlab_ci/gitlab-ci/config/
ADD start /start

# Start everything
EXPOSE 22 8080
