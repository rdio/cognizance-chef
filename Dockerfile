FROM ubuntu:12.04

RUN apt-get update
RUN apt-get install -y curl

RUN curl -o /usr/local/src/etcd-v0.4.6-linux-amd64.tar.gz -L https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz
RUN cd /usr/local/src/ && tar xvzf etcd-v0.4.6-linux-amd64.tar.gz && chmod 755 etcd-v0.4.6-linux-amd64/etcd
RUN cd /usr/bin/ && ln -s /usr/local/src/etcd-v0.4.6-linux-amd64/etcd

EXPOSE 4001
EXPOSE 7001

CMD ["/usr/bin/etcd"]
