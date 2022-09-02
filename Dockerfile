FROM ubuntu 

# debian provides actual mysql, while alpine provides mariadb

RUN apt-get update
RUN apt-get install -y mysql-client 
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y cron	

RUN python3 -m pip install awscli

# this prevent "TERM environment variable not set.""
ENV TERM dumb

RUN mkdir -p /backup
ADD . /backup
RUN chmod +x /backup/bin/*

WORKDIR /backup/bin/

ENTRYPOINT ["/backup/bin/entrypoint"]
