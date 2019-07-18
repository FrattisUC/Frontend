FROM python:3.5-alpine

RUN apk add --update \
    supervisor \
    patch \
    ca-certificates \
    perl \
    musl-dev \
    openssl-dev \
    libffi-dev \
    python-dev \
    gcc \
    redis \
    py-virtualenv

RUN mkdir /code
WORKDIR /code

COPY . .

RUN pip3 --timeout=60 install --no-cache-dir -r requirements.txt

RUN ./manage.py assets build
RUN ./manage.py createdb
#RUN ./manage.py seed

EXPOSE 5000
CMD [ "python3", "./manage.py", "runserver"]
