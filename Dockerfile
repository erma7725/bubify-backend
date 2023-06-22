FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="jonas@norlinder.nu"

RUN apt update
RUN apt upgrade -y

RUN apt install -y nginx maven
#git && \
# rm -rf /var/lib/apt/lists/* && \
# apt clean

RUN apt install -y git wget apt-transport-https gnupg curl sudo tmux emacs mysql-client nano htop
RUN mkdir -p /etc/apt/keyrings
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
RUN echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update
RUN apt install -y temurin-17-jdk

RUN useradd -ms /bin/bash bubify
RUN usermod -aG sudo bubify

RUN echo "bubify     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/bubify

USER bubify

RUN mkdir -p au_backups
RUN mkdir -p profile_pictures
RUN mkdir -p keystore
RUN mkdir -p backend
RUN mkdir -p backend/target
RUN mkdir -p logs

# Setup intermediate certificate -- only needed for deployment
WORKDIR /home/bubify/keystore
RUN keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 -keystore keystore.jks -validity 3650 -storepass password -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"
RUN keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore.p12 -validity 3650 -storepass password -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"

ENV AU_KEY_ALIAS=tomcat
ENV AU_KEY_STORE=/home/bubify/keystore/keystore.p12
ENV AU_KEY_STORE_PASSWORD=password
ENV AU_KEY_STORE_TYPE=PKCS12

ENV AU_BACKEND_HOST=
ENV AU_FRONTEND_HOST=
ENV AU_APP_API=
ENV AU_APP_WEBSOCKET=

ENV AU_DB_HOST=localhost
ENV AU_DB_PORT=3306
ENV AU_DB_NAME=ioopm
ENV AU_DB_USER=ioopm
ENV AU_DB_PASSWORD=CHANGE_ME
ENV AU_GITHUB_CLIENT_ID=CHANGE_ME
ENV AU_GITHUB_CLIENT_SECRET=CHANGE_ME

ENV AU_PROFILE_PICTURE_DIR=/home/bubify/profile_pictures/
ENV AU_BACKUP_DIR=/home/bubify/au_backups/

WORKDIR /home/bubify
COPY --chown=bubify:bubify start.sh /home/bubify
RUN chmod +x start.sh

EXPOSE 8900
CMD ["./start.sh"]
