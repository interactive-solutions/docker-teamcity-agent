FROM jetbrains/teamcity-agent:2018.2.2


RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
    python-dev curl wget software-properties-common language-pack-en && \
    apt-get upgrade -y --no-install-recommends && \ 
    rm -rf /var/lib/apt/lists/*

# Fix locale.
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN locale-gen en_US && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Prepare for node.js installation
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install php and ansible
RUN add-apt-repository ppa:ondrej/php && \
    add-apt-repository ppa:ansible/ansible && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends php7.2-mbstring php7.2-zip php7.2-cli php7.2-xml php7.2-intl build-essential ansible nodejs yarn git sshpass unzip python3-setuptools python3-pip && \
    rm -fr /var/lib/apt/lists/*

# Install docker-composer
RUN curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# Install golang
RUN wget -qO- https://storage.googleapis.com/golang/go1.11.5.linux-amd64.tar.gz | tar xz -C /usr/local
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
RUN pip3 install setuptools awscli
