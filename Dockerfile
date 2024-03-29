FROM ubuntu:16.04
MAINTAINER Cole Brokamp cole.brokamp@gmail.com

RUN apt-get update && apt-get install -y software-properties-common \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable

RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/  " >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        libgdal-dev \
        libgeos-dev \
        libproj-dev \
        liblwgeom-dev \
        libudunits2-dev \
        r-base-dev \
        && apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set default CRAN repo and DL method
RUN echo 'options(repos=c(CRAN = "https://cran.rstudio.com/"), download.file.method="libcurl")' >> /etc/R/Rprofile.site

RUN R -e "install.packages(c('argparser', 'tidyverse', 'sf', 'stringr'))"

# install devel version of automagic package to install package dependencies
# RUN R -e "install.packages('remotes'); remotes::install_github('cole-brokamp/automagic')"

RUN mkdir /app_source

# COPY deps.yaml /app_source/deps.yaml
# RUN R -e "setwd('/app_source'); automagic::automagic()"

COPY . /app_source

ENTRYPOINT ["/app_source/crew_census.R"]
