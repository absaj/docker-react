#section 1 Build phase. Sole purpose install dependencies and build the app. We will use the build output in the 
#next phase to run the app.
FROM node:alpine AS builder
WORKDIR '/app'
COPY package.json .  
#while copying package.json, we are not copying the node_modules folder, 
#so that we can run npm install and get the latest dependencies. If we copy the node_modules folder, 
#we might end up with old dependencies which might cause issues.
RUN npm install
#making setup ready with the latest dependencies, now we can copy the rest of the files and
COPY . . 
#copy our source code directly in to the container, so that we can build the app. We need to copy the source code
#to the container in the build phase because we need to run npm run build to create the build output, which will 
#be used in the next phase to run the app.
# the volume mapping is only for the development environment, in production we will not use volume mapping, so we need to copy the files in the build phase.
RUN npm run build
#the output of the build command will be in the build folder, which we will use in the next phase to run the app.
#/app/build is the output of the build command, which will be used in the next phase to run the app.


FROM nginx:alpine
#we are using nginx as a web server to serve our react app. We will copy the build output from the previous phase to the
#nginx html folder, so that nginx can serve our react app.
COPY --from=builder /app/build /usr/share/nginx/html
# everything that is inside this /usr/share/nginx/html folder will be served by nginx, so we need to copy the build output to 
#this folder. 
#copy the build output from the previous phase to the nginx html folder, so that nginx can serve our react app.
EXPOSE 80
#nginx listens on port 80, so we need to expose port 80 to access our app.
CMD ["nginx", "-g", "daemon off;"]
#the command to run nginx in the foreground, so that the container does not exit immediately after starting nginx. 
#This is a common practice when running nginx in a container, as it allows the container to keep running and serve the app.
