FROM nginx:stable-alpine
#EXPOSE 80
RUN rm /etc/nginx/conf.d/default.conf
RUN rm /usr/share/nginx/html/*
COPY config/*.conf ./etc/nginx/conf.d/
COPY cert/front-selfsigned.crt /etc/ssl/certs/
COPY cert/front-selfsigned.key /etc/ssl/private/

#Custom
RUN apk update && apk upgrade
RUN apk -q add curl vim libcap
CMD ["nginx", "-g", "daemon off;"]
