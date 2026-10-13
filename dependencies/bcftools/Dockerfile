FROM gcc:15

RUN wget https://github.com/samtools/bcftools/releases/download/1.22.1/bcftools-1.22.1.tar.bz2 && \
    tar -xf bcftools-1.22.1.tar.bz2 && \
    cd bcftools-1.22.1 && \
    make && \
    cd htslib-1.22.2 && \
    make

FROM debian:13

RUN apt-get -y update && \
        apt-get -y install \
        curl

COPY --from=0 /bcftools-1.22.1/bcftools /usr/local/bin/bcftools
COPY --from=0 /bcftools-1.22.1/htslib-1.22.2/tabix /usr/local/bin/tabix
COPY --from=0 /bcftools-1.22.1/htslib-1.22.2/bgzip /usr/local/bin/bgzip

CMD ["bcftools", "-h"]
