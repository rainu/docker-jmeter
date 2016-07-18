FROM java:openjdk-8-jdk
MAINTAINER rainu <rainu@raysha.de>

ENV JMETER_LINK http://apache.mirror.iphh.net//jmeter/binaries/apache-jmeter-3.0.tgz

#download and extract JMeter
RUN wget -nv $JMETER_LINK -O /tmp/jmeter.tar.gz &&\
	tar -xzvf /tmp/jmeter.tar.gz -C /opt/ && mv /opt/$(ls /opt/) /opt/jmeter/ &&\
	rm /tmp/jmeter.tar.gz 

#make home directory for jmeter user
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/jmeter && \
    echo "jmeter:x:${uid}:${gid}:JMeter User,,,:/home/jmeter:/bin/bash" >> /etc/passwd && \
    echo "jmeter:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /opt/jmeter &&\
    chown ${uid}:${gid} -R /home/jmeter

USER jmeter

ENTRYPOINT ["/opt/jmeter/bin/jmeter.sh"]
