FROM node:8-stretch as intermediate

ENV serial 202098761

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list

RUN apt-get update -y
RUN apt-get install -y
RUN apt install -y git
RUN apt install -y make
RUN apt install -y python3
RUN apt install -y cmake
RUN apt install -y flex
RUN apt install -y bison
RUN apt install -y libglib2.0-dev
RUN apt install -y libgcrypt20-dev
RUN apt install -y libspeex-dev
RUN apt install -y libc-ares-dev
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /out
RUN mkdir -p /usr/src
RUN mkdir -p /var/run

WORKDIR /usr/src

# 버전 주의
RUN git clone https://github.com/qxip/node-webshark /usr/src/node-webshark
# RUN git clone https://github.com/Fhwang0926/node-webshark /usr/src/node-webshark
# 버전 주의
RUN git clone https://github.com/wireshark/wireshark /usr/src/wireshark

WORKDIR /usr/src/wireshark
# RUN ls -al
# RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2.tar.gz 
# RUN tar -xvf cmake-3.18.2.tar.gz
# RUN cd cmake-3.18.2
# RUN ./bootstrap
# RUN make
# RUN make install
apt install libglib2.0 libglib2.0-dev libgtk-3-dev libgtk-3

RUN echo 1 && wget https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3.tar.gz  \
&& tar -xvf cmake-3.16.3.tar.gz \
&& cd cmake-3.16.3 \
&& ./bootstrap \
&& make \
&& make install

RUN cmake --version 
RUN ../node-webshark/sharkd/build.sh

RUN apt-get install software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install python3.6

wget https://www.python.org/ftp/python/3.8.17/Python-3.8.17.tar.xz
tar -xf Python-3.8.17.tar.xz 
./configure --enable-optimizations --enable-shared
mv Python-3.8.17 /usr/local/share/python3.8
./configure --enable-optimizations --enable-shared
make && make -j 5 && make altinstall
ldconfig /usr/local/share/python3.8
python3 --version

cd /opt
wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
tar xzf Python-3.8.12.tgz
cd Python-3.8.12
./configure --enable-optimizations

FROM node:10-stretch

RUN cat /etc/apt/sources.list
# RUN echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list
# RUN echo "deb http://security.debian.org/ stretch/updates main contrib non-free" > /etc/apt/sources.list
# RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
# RUN sed -i s/security.debian.org/archive.debian.org/g /etc/apt/sources.list



RUN apt-get update

RUN apt update -y
RUN apt install -y git
RUN apt install -y libglib2.0-0
RUN apt install -y speex
RUN apt install -y libspeex-dev
RUN apt install -y libc-ares2
    # && apt install -y git libglib2.0-0 speex libspeex-dev libc-ares2 \
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /captures
VOLUME /captures

COPY --from=intermediate /out /out
RUN cd / && tar zxvf /out/sharkd.tar.gz && rm -rf /out/sharkd.tar.gz

# ENV CAPTURES_PATH=/captures/

# RUN git clone --single-branch --branch master https://github.com/qxip/node-webshark /usr/src/node-webshark
COPY . /usr/src/node-webshark

WORKDIR /usr/src/node-webshark
RUN npm i -g browserify-lite && browserify-lite --standalone webshark ./web/js/webshark.js --outfile web/js/webshark-app.js

WORKDIR /usr/src/node-webshark/api
RUN npm install && npm audit fix

RUN echo "#!/bin/bash" > /entrypoint.sh && \
    echo "CAPTURES_PATH=$CAPTURES_PATH npm start" >> /entrypoint.sh && chmod +x /entrypoint.sh
    
EXPOSE 8085

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "npm", "start" ]
