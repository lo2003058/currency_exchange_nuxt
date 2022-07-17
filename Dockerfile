FROM node:14.18.3-alpine

WORKDIR .
RUN pwd && ls -l

RUN mkdir -p /app
COPY . /app
WORKDIR /app

COPY ../.env /app

#only for new m1 mac, because no python v2.x installed(local)
#RUN apk add --no-cache python2 g++ make

# update and install dependency
RUN apk update && apk upgrade
RUN apk add git

ENV HOST 0.0.0.0
EXPOSE 3000

RUN npm install
RUN npm run build

CMD [ "npm", "start" ]
