FROM node:13.12.0-alpine

WORKDIR /usr/src/lutri

COPY package.json ./
COPY yarn.lock ./
RUN yarn install --no-progress

COPY . ./

EXPOSE 3000

CMD ["yarn", "start"]