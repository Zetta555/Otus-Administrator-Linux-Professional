FROM alpine:3.13
RUN apk update && apk add nginx && rm -rf /var/cache/apk/*
RUN adduser -D -g 'www' www && mkdir /www && chown -R www:www /var/lib/nginx && chown -R www:www /www

COPY index.html /www
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]