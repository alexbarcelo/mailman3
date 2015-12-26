FROM python:3.5

MAINTAINER Alex Barcelo <alex.barcelo@gmail.com>

#########################################################
# Prepare the user mailman, which will run the commands #
#########################################################
# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove ca-certificates wget

########################################
# Proceed to prepare the mailman stuff #
########################################
# Mailman developers recommend that path, although it is quite irrelevant in a docker
RUN mkdir -p /opt/mailman
WORKDIR /opt/mailman

# Install some extras required for psycopg2 (Postgres Python wrapper)
RUN apt-get update && apt-get install -y \
                postgresql-client libpq-dev \
                gcc \
        --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Python requirements
COPY requirements.txt /opt/mailman/
RUN pip install --no-cache-dir -r requirements.txt

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 2500
CMD ["start"]
