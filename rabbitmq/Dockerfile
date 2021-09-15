FROM rabbitmq:3.8-alpine
RUN rabbitmq-plugins enable rabbitmq_web_mqtt \
;rabbitmq-plugins enable rabbitmq_auth_backend_http
RUN alias ll="ls -alhF"
COPY cert/front-selfsigned.crt /etc/ssl/certs/
COPY cert/front-selfsigned.key /etc/ssl/private/

RUN touch /etc/rabbitmq/conf.d//mqtt.conf \
;echo "web_mqtt.tcp.port = 15675" >> /etc/rabbitmq/conf.d/mqtt.conf

#web_mqtt.ssl.port       = 15676                                                  
#web_mqtt.ssl.backlog    = 1024                                                   
#web_mqtt.ssl.cacertfile = /etc/ssl/certs/front-selfsigned.crt                    
#web_mqtt.ssl.certfile   = /etc/ssl/private/front-selfsigned.pem                  
#web_mqtt.ssl.keyfile    = /path/to/server_key.pem   
