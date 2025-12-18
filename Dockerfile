
FROM node

ENV MONGO_INITDB_ROOT_USERNAME=root \
      MONGO_INITDB_ROOT_PASSWORD=example

RUN mkdir -p testApp

#copy from parent folder to newly created folder testApp
COPY . /testApp        

CMD ["node","/testApp/server.js"]


 