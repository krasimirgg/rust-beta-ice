FROM ubuntu:focal

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git \
  wget \
  rsync \
  lld
RUN apt-get update

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup install beta-2022-06-09
RUN rustup update

WORKDIR /example
ADD run.sh /example
ADD serde /example/serde
ADD serde_derive /example/serde_derive
ADD gsgdt /example/gsgdt

RUN git clone https://github.com/rust-lang/rust || true
RUN (cd rust && git checkout f19ccc2e8dab09e542d4c5a3ec14c7d5bce8d50e)
RUN (cd rust && git submodule update --init --recursive)
