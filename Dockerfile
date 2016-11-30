FROM node:latest


WORKDIR /home/app
ADD . /home/app
 
RUN npm install
RUN npm run build


# Install dependencies


# Tell Docker we are going to use this port
EXPOSE 9000 8080

# The command to run our app when the container is run
CMD ["npm", "start"]
