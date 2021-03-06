# Inherit from Heroku's stack
FROM heroku/cedar:14

MAINTAINER Phaninder "hello@phaninder.com"

ENV DEBIAN_FRONTEND     noninteractive
ENV LIBPOSTAL_DIR       /opt/libpostal
ENV LIBPOSTAL_DATA_DIR  /opt/libpostal_data


########################################
# libpostal
########################################
RUN echo "deb http://cz.archive.ubuntu.com/ubuntu trusty main" > /etc/apt/sources.list

RUN apt-get update && apt-get -qq update && apt-get install -y --force-yes \
  libsnappy-dev \
  autoconf \
  automake \
  libtool \
  pkg-config \
  git

RUN git clone https://github.com/openvenues/libpostal $LIBPOSTAL_DIR
WORKDIR $LIBPOSTAL_DIR
COPY ./build_libpostal.sh .
RUN ./build_libpostal.sh
##############

# After typical install swap the address parser with the new one (https://github.com/openvenues/libpostal/issues/119#issuecomment-249030219)
WORKDIR $LIBPOSTAL_DATA_DIR/libpostal
RUN rm -rf address_parser
RUN wget https://libpostal.s3.amazonaws.com/mapzen_sample/parser_full.tar.gz
RUN tar -xvzf parser_full.tar.gz
RUN ln -s parser_full address_parser
RUN rm parser_full.tar.gz
##############

WORKDIR $LIBPOSTAL_DIR

CMD ["./src/libpostal"]
