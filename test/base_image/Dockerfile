FROM antora-onbuild

# Clean up
RUN rm -rf /antora/
RUN rm -rf /var/www/localhost/htdocs/*

# Register the base's ONBUILD instructions
ONBUILD COPY . /antora/
ONBUILD RUN generate.sh
