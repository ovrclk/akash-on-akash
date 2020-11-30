FROM ovrclk/akash:e36f8c0

EXPOSE 8080
EXPOSE 26656
EXPOSE 26657

RUN apt-get update && apt-get install --no-install-recommends --assume-yes python3 p7zip-full && apt-get clean

RUN mkdir /node

COPY genesis.json /node/
COPY app.toml /node/
COPY config.toml /node/

COPY run.sh /node/
RUN chmod 555 /node/run.sh

CMD /node/run.sh
