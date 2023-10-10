# Production build
FROM nginx:1.23-alpine

COPY --from=inspectorgadget12/lambda-runtime-adapter /lambda-runtime-adapter /opt/extensions/lambda-adapter

# Update depedencies (Eliminate vulnerabilities)
RUN apk update && apk upgrade

# config files
COPY ./lambda-runtime/nginx.conf                /etc/nginx/nginx.conf
ADD ./lambda-runtime/public-html/               /usr/share/nginx/html/
COPY ./lambda-runtime/bootstrap                 /opt/bootstrap

ENTRYPOINT /opt/bootstrap
