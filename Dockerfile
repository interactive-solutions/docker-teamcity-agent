FROM ubuntu:16.04

ENV AGENT_DIR  /opt/buildAgent

RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
    python-dev curl wget software-properties-common language-pack-en && \
    rm -rf /var/lib/apt/lists/*

# Fix locale.
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN locale-gen en_US && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true 


# Install java-8-oracle
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && add-apt-repository -y ppa:webupd8team/java \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      oracle-java8-installer ca-certificates-java \
    && rm -rf /var/lib/apt/lists/* /var/cache/oracle-jdk8-installer/*.tar.gz /usr/lib/jvm/java-8-oracle/src.zip /usr/lib/jvm/java-8-oracle/javafx-src.zip \
      /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts \
    && ln -s /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts \
    && update-ca-certificates

# Prepare for node.js installation
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

# Install php and ansible
RUN add-apt-repository ppa:ondrej/php && \
    add-apt-repository ppa:ansible/ansible && \
    add-apt-repository ppa:masterminds/glide && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-engine php7.1-mbstring php7.1-zip php7.1-cli glide build-essential ansible nodejs yarn git sshpass python-dev python-pip python-setuptools libssl-dev libffi-dev unzip dmsetup openssh-server && \
    rm -fr /var/lib/apt/lists/*

# Install golang
RUN wget -qO- https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz | tar xz -C /usr/local
ENV PATH /usr/local/go/bin:$PATH

# Setup teamcity user
RUN adduser --disabled-password --gecos "" teamcity \
    && usermod -a -G docker teamcity

RUN mkdir /home/teamcity/.ssh/
ADD config /home/teamcity/.ssh/config
RUN touch /home/teamcity/.ssh/known_hosts
RUN chown -hR teamcity:teamcity /home/teamcity/.ssh

# Setup golang workspace
ENV GOPATH /home/teamcity/golang
RUN mkdir -p /home/teamcity/golang/src /home/teamcity/golang/pkg /home/teamcity/golang/bin

RUN pip install --upgrade docker-compose pip
RUN yarn global add bower gulp tsd typings typescript 

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker
ADD docker-entrypoint.sh /docker-entrypoint.sh

# Allow bower to install from teamcity
RUN chmod -R 777 /usr/lib/node_modules

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /var/lib/docker
VOLUME /opt/buildAgent
VOLUME /home/teamcity/golang


EXPOSE 9090
