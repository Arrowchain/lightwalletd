FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  build-essential \
  libssl-dev \
  pkg-config \
  libc6-dev \
  m4 \
  g++-multilib \
  nginx \
  curl \
  wget \
  openssl \
  ca-certificates

RUN wget -q --no-check-certificate https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
RUN tar -xf go1.13.4.linux-amd64.tar.gz
RUN mv go /usr/local

RUN openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Arrowchain/CN=wallet.arrowchain.net" \
  -addext "subjectAltName=DNS:wallet.arrowchain.net" \
  -newkey rsa:4096 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt

RUN update-ca-certificates

# if using an issued cert, use nginx reverse proxy
#RUN rm /etc/nginx/sites-enabled/default
#COPY res/nginx.conf /etc/nginx/sites-enabled/default
#RUN nginx -t

ENV GOPATH=$HOME/work
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

COPY . /lightwalletd
WORKDIR /lightwalletd

#CMD nginx && go run cmd/server/main.go -bind-addr 0.0.0.0:9067 -conf-file /lightwalletd/res/arrow.conf -tls-cert /etc/ssl/certs/nginx-selfsigned.crt -tls-key /etc/ssl/private/nginx-selfsigned.key
CMD go run cmd/server/main.go -bind-addr 0.0.0.0:443 -conf-file /lightwalletd/res/arrow.conf -tls-cert /etc/ssl/certs/nginx-selfsigned.crt -tls-key /etc/ssl/private/nginx-selfsigned.key
