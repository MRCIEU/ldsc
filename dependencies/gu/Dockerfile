FROM alpine:3.23

RUN apk add --update --no-cache \
    build-base \
    cmake \
    curl \
    git

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh -s -- -y

RUN git clone https://github.com/MRCIEU/gwas-utils.git && \
    cd gwas-utils && \
    git checkout v0.15.0 && \
    source $HOME/.cargo/env && \
    cargo build --release && \
    mv target/release/gu /usr/local/bin/

CMD [ "gu", "-h" ]
