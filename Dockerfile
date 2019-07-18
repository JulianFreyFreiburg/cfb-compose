FROM tomcat:8.5-jre8

#USER 1000:1000

ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"

#Environment variables
ENV GN_VERSION 3.6.0
ENV GN_DOWNLOAD_MD5 06601ea4b16e4f8e806c7369ea0060ae
ENV POSTGRES_DB_USERNAME www-user
ENV POSTGRES_DB_PASSWORD www-user
ENV POSTGRES_DB_HOST postgres

WORKDIR $CATALINA_HOME/webapps

# Copy the current directory contents into the container at webapps
COPY . $CATALINA_HOME/webapps/

#RUN mkdir -p geonetwork && \
#     unzip -e $GN_FILE -d $CATALINA_HOME/webapps/geonetwork 

CMD ["catalina.sh", "run"]

RUN apt-get update && apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

#Set PostgreSQL as default GN DB
#RUN sed -i -e 's#<import resource="../config-db/h2.xml"/>#<!--<import resource="../config-db/h2.xml"/> -->#g' $CATALINA_HOME/webapps/#geonetwork/WEB-INF/config-node/srv.xml && \
#sed -i -e 's#<!--<import resource="../config-db/postgres.xml"/>-->#<import resource="../config-db/postgres.xml"/>#g' $CATALINA_HOME/webapps/#geonetwork/WEB-INF/config-node/srv.xml



#Initializing database & connection string for GN
COPY ./docker-entrypoint-pg.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

COPY ./jdbc.properties $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-db/jdbc.properties

CMD ["catalina.sh", "run"]


