FROM python:3.5-alpine

RUN apk add --update \
    supervisor \
    patch \
    ca-certificates \
    nginx \
    perl \
    musl-dev \
    openssl-dev \
    libffi-dev \
    python-dev \
    gcc \
    redis \
    py-virtualenv

RUN mkdir /code/
WORKDIR /code/

ADD requirements.txt .

RUN virtualenv -p python3 env
RUN source env/bin/activate
RUN pip3 --timeout=60 install --no-cache-dir -r requirements.txt

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ADD . .

RUN ./manage.py assets build

RUN rm -rf /var/cache/apk/*

RUN ./manage.py createdb
RUN ./manage.py seed

EXPOSE 5000

CMD ["/manage.py runserver"]
