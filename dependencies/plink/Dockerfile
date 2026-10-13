FROM alpine:3.23

RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20250819.zip && \
    unzip plink_linux_x86_64_20250819.zip && \
    mv plink prettify /usr/local/bin/ && \
    rm plink_linux_x86_64_20250819.zip toy.map toy.ped

CMD ["plink", "-h"]
