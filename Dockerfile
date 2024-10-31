# Install Operating system and dependencies
FROM ubuntu:20.04 AS build-env

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3
RUN apt-get clean

ENV DEBIAN_FRONTEND=dialog
ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

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

# Record the exposed port
# See the port below
#EXPOSE 9000

# make server startup script executable and start the web server
#RUN ["chmod", "+x", "/app/server/server.sh"]

#ENTRYPOINT [ "/app/server/server.sh"]

FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# EXPOSE <EXPOSE PORT THAT YOU WANT>
EXPOSE 80