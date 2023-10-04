# Production build
FROM nginx:latest

COPY --from=inspectorgadget12/minimal_lambda_adapter /lambda-adapter /opt/extensions/lambda-adapter

# config files
COPY ./lambda-runtime/nginx.conf                /etc/nginx/nginx.conf
ADD ./lambda-runtime/public-html/               /usr/share/nginx/html/
COPY ./lambda-runtime/bootstrap                 /opt/bootstrap

ENTRYPOINT /opt/bootstrap