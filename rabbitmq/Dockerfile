FROM rabbitmq:3.8-alpine
RUN rabbitmq-plugins enable rabbitmq_web_mqtt \
;rabbitmq-plugins enable rabbitmq_auth_backend_http
RUN alias ll="ls -alhF"
RUN touch /etc/rabbitmq/conf.d//mqtt.conf \
;echo "web_mqtt.tcp.port = 15675" >> /etc/rabbitmq/conf.d//mqtt.conf
