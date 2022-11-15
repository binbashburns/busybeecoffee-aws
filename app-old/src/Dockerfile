FROM public.ecr.aws/nginx/nginx:1.23-alpine
LABEL maintainer="pro.mattburns@gmail.com"
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./web /usr/share/nginx/html/
EXPOSE 80