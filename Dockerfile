FROM ghcr.io/ovrclk/akash:0.12.1
LABEL org.opencontainers.image.source https://github.com/ovrclk/akash-on-akash

EXPOSE 8080
EXPOSE 26656
EXPOSE 26657
EXPOSE 1317
EXPOSE 9090

RUN apt-get update && apt-get install --no-install-recommends --assume-yes ca-certificates python3 python3-toml p7zip-full curl && apt-get clean

RUN mkdir /node

COPY app.toml /node/
COPY config.toml /node/

COPY run.sh /node/
RUN chmod 555 /node/run.sh

COPY ./patch_config_toml.py /node/

CMD /node/run.sh
