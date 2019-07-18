# Base image
FROM nginx:alpine
# Install dependencies
RUN apk update && apk add bash

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
