FROM node:18
# RUN cat /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list

RUN apt update -y
RUN apt install -y git
RUN apt install -y libglib2.0-0
RUN apt install -y speex
RUN apt install -y libspeex-dev
RUN apt install -y libc-ares2
# RUN rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /captures
# VOLUME /captures

# COPY --from=intermediate /out /out

# RUN cd / && tar zxvf /out/sharkd.tar.gz && rm -rf /out/sharkd.tar.gz
# ENV CAPTURES_PATH=/captures/
# RUN git clone --single-branch --branch master https://github.com/qxip/node-webshark /usr/src/node-webshark

RUN ln -s /usr/src/node-webshark/captures /captures
COPY . /usr/src/node-webshark
RUN mkdir -p /usr/src/node-webshark/captures

# RUN npm i -g browserify-lite && browserify-lite --standalone webshark ./web/js/webshark.js --outfile web/js/webshark-app.js

WORKDIR /usr/src/node-webshark/api
RUN npm install
RUN npm audit fix

RUN echo "#!/bin/bash" > /entrypoint.sh
RUN echo "rm \"$SHARKD_SOCKET\"" >> /entrypoint.sh
RUN echo "CAPTURES_PATH=$CAPTURES_PATH npm start" >> /entrypoint.sh
RUN chmod +x /entrypoint.sh
    
EXPOSE 8085

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "npm", "start" ]
