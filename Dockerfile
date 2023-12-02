FROM node:8-stretch as intermediate

ENV serial 202098761

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

RUN git clone https://github.com/qxip/node-webshark /usr/src/node-webshark
RUN git clone https://github.com/wireshark/wireshark /usr/src/wireshark

WORKDIR /usr/src/wireshark
RUN ../node-webshark/sharkd/build.sh


FROM node:10-stretch

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

ENV CAPTURES_PATH=/captures/

# RUN git clone --single-branch --branch master https://github.com/qxip/node-webshark /usr/src/node-webshark
COPY . /usr/src/node-webshark

WORKDIR /usr/src/node-webshark
RUN npm i -g browserify-lite && browserify-lite --standalone webshark ./web/js/webshark.js --outfile web/js/webshark-app.js

WORKDIR /usr/src/node-webshark/api
RUN npm install && npm audit fix

RUN echo "#!/bin/bash" > /entrypoint.sh && \
    echo "CAPTURES_PATH=/captures/ npm start" >> /entrypoint.sh && chmod +x /entrypoint.sh
    
EXPOSE 8085

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "npm", "start" ]
