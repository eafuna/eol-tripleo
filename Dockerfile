FROM centos
LABEL maintainer=rdoci
LABEL name=quickstart


COPY . /quickstart
WORKDIR /quickstart

# RUN cd /etc/yum.repos.d/
# RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
# RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

#https://stackoverflow.com/questions/59993633/centos-8-yum-dnf-error-failed-to-download-metadata-for-repo
#RUN dnf clean all && rm -r /var/cache/dnf  && dnf upgrade -y && dnf update -y 

#RUN yum install -y sudo && ./quickstart.sh --install-deps

#CMD ["/quickstart/quickstart.sh", "--no-clone", "--bootstrap", "${VIRTHOST}"]
