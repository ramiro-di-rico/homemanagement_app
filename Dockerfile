# Install Operating system and dependencies
FROM ubuntu:24.04 AS build-env

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3
RUN apt-get clean

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN flutter build web --release --base-href /homemanagement_app/

# clean up flutter SDK
RUN rm -rf /usr/local/flutter

# this line below makes the web app not work
# clean up app build directory
#RUN rm -rf /app/build

# clean up app .dart_tool directory
RUN rm -rf /app/.dart_tool

# clean up app linux directory
RUN rm -rf /app/linux

FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# EXPOSE <EXPOSE PORT THAT YOU WANT>
EXPOSE 80