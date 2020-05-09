#Dockerised version of p5 Manager
#https://github.com/chiunhau/p5-manager

FROM node
RUN apt-get update && apt-get install -y vim
RUN npm install -g p5-manager
WORKDIR /app
CMD p5 s
