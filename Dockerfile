# MongoD BAgent image
# Version 1.0
# MongoDB management
# Data 04/13/2018

FROM ubuntu:16.04

ENV MONGODB_DATADIR /data/db
ENV BACKUP_DATADIR /backup
ENV KUBECONFIG /admin.conf
#ENV KUBECONFIG /root/.admin.conf

COPY root /
#COPY agent /root/agent
#COPY admin.conf /root/.admin.conf
#COPY mongo /mongo
#COPY ez_setup.py /ez_setup.py
#COPY influxdb /influxdb
#COPY supervisor /supervisor
#COPY pymongo /pymongo

RUN apt-get update && \
    apt-get install -y apt-transport-https curl python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \ 
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main"  > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    cd / && chmod +x ez_setup.py && \
    ./ez_setup.py && \
    pip3 install uwsgi && \
    cd /pymongo && python setup.py install && \
    cd /prometheus_client-0.4.2 && python setup.py install && \
    cd /supervisor && python setup.py install && \
    cd /Flask-0.12.2 && python setup.py install && \
    cd /Flask-Script-2.0.6 && python setup.py install && \
    cd /Flask-RESTful-0.3.6 && python setup.py install && \
    mkdir -p /conf && \
    mkdir -p /etc/supervisor && \
    mkdir -p ${MONGODB_DATADIR} && \
    mkdir -p ${BACKUP_DATADIR} && \
    mv /mongo/bin/* /usr/bin/ && \
    rm -rf /var/lib/apt/lists/* && \
    apt remove -y apt-transport-https curl && \
    apt autoremove -y && \
    apt autoclean -y 

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY uwsgi.ini /conf/uwsgi.ini
COPY mongodb_exporter /usr/local/bin/mongodb_exporter
COPY mongodb_exporter.sh /usr/local/bin/

CMD ["supervisord","-c","/etc/supervisor/supervisord.conf"]
