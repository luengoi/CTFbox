FROM ubuntu:eoan
MAINTAINER matterbeam <mb@matterbeam.com>

ENV LC_CTYPE C.UTF-8

COPY bin/apt-get-install /usr/local/bin/apt-get-install
RUN chmod +x /usr/local/bin/apt-get-install

RUN dpkg --add-architecture i386 && \
    apt-get-install build-essential libtool g++ gcc curl wget automake autoconf \
    python3 python3-dev python3-pip git unzip p7zip-full sudo ca-certificates \
    strace ltrace gdb gdb-multiarch ruby-dev libssl-dev libffi-dev zsh \
    libc6:i386 libncurses5:i386 libstdc++6:i386 && \
    python3 -m pip install virtualenvwrapper

RUN useradd -d /home/ctf -m -s /bin/zsh ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

COPY .git /home/ctf/tools/.git
COPY bin/manage /home/ctf/tools/bin/
COPY bin/tools-venv /home/ctf/tools/bin/
COPY bin/tools-pip /home/ctf/tools/bin/
RUN chown -R ctf:ctf /home/ctf/tools

USER ctf
WORKDIR /home/ctf/tools
RUN git checkout .
RUN bin/manage -s setup

ARG TOOLS
RUN for tool in $TOOLS; do bin/manage -s install "$tool"; done

WORKDIR /home/ctf
