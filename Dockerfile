FROM jetbrains/teamcity-agent:2017.1.3

# Fix locale.
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN locale-gen en_US && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
    python-dev curl wget software-properties-common language-pack-en && \
    apt-get upgrade -y --no-install-recommends && \ 
    rm -rf /var/lib/apt/lists/*

# Prepare for node.js installation
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install php and ansible
RUN add-apt-repository ppa:ondrej/php && \
    add-apt-repository ppa:ansible/ansible && \
    add-apt-repository ppa:masterminds/glide && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends php7.1-mbstring php7.1-zip php7.1-cli glide build-essential ansible nodejs yarn git sshpass unzip && \
    rm -fr /var/lib/apt/lists/*

# Install docker-composer
RUN curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# Install golang
RUN wget -qO- https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz | tar xz -C /usr/local
RUN mkdir -p /root/golang/src /root/golang/pkg /root/golang/bin

# setup the paths
ENV PATH /usr/local/go/bin:/root/golang/bin:$PATH:
ENV GOPATH /root/golang
RUN go get github.com/vektra/mockery/.../

# Install NPM dependencies
RUN npm install -g bower gulp tsd typings typescript 

RUN mkdir /root/.ssh/
ADD config /root/.ssh/config
RUN touch /root/.ssh/known_hosts
RUN chown -hR root:root /root/.ssh

# Optimize network
RUN echo "127.0.0.1 localunixsocket.local localunixsocket" >> /etc/hosts

