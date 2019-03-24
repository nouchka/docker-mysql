ARG  BASE_TAG=5.5
FROM mariadb:${BASE_TAG}
LABEL maintainer="Jean-Avit Promis docker@katagena.com"
LABEL org.label-schema.vcs-url="https://github.com/nouchka/docker-mysql"

ARG DOCKER_TAG=latest
ARG MYSQLVERSION=5.5
## MINOR_TAG=5.5.63-MariaDB 10.3.13-MariaDB
LABEL version="${DOCKER_TAG}"

ENV DEBIAN_FRONTEND=noninteractive

ARG APT_KEY=93C4A3FD7BB9C367

RUN export uid=1000 gid=1000 && \
	mkdir -p /home/developer/db && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	chown ${uid}:${gid} -R /home/developer

WORKDIR /home/developer/db/
USER developer

CMD [ "mysql", "--version" ]
