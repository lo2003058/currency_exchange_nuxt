FROM node:alpine

# create destination directory
RUN mkdir -p /usr/src/nuxt-app
WORKDIR /usr/src/nuxt-app

#only for new m1 mac, because no python v2.x installed
#RUN apk add --no-cache python2 g++ make

# update and install dependency
RUN apk update && apk upgrade
RUN apk add git

# copy the app, note .dockerignore
COPY . /usr/src/nuxt-app/
RUN npm install

# build necessary, even if no static files are needed,
# since it builds the server as well
RUN npm run build

FROM nginx
COPY --from=0 /dist /usr/share/nginx/html
