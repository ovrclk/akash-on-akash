FROM ovrclk/akash:e36f8c0
LABEL org.opencontainers.image.source https://github.com/ovrclk/akash-on-akash

EXPOSE 26657

RUN mkdir /node
RUN apt-get update && apt-get install --assume-yes --no-install-recommends jq && apt-get clean 

COPY run.sh /node/
RUN chmod 555 /node/run.sh

CMD /node/run.sh
