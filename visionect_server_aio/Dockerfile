ARG BUILD_FROM
FROM ${BUILD_FROM}

# Kopiujemy nasz skrypt
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
