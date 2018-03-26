FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY content /usr/share/nginx/html

COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]