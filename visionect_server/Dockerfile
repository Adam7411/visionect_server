ARG BUILD_FROM
FROM $BUILD_FROM

# HA Add-on base setup
RUN apk add --no-cache bash

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
