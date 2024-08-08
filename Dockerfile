# systex=docker/dockerfile:1
FROM node:21.1.0-alpine as base
# FROM harbor.entitymaker.com/library/node:21.1.0-alpine as base

ARG MODE=production
ARG USER_ID=1001
ARG GROUP_ID=1001
ARG USER_NAME="demo"
ARG GROUP_NAME="demo"
ARG WORK_DIR="/usr/src/app"

# Install additional tools and setup app user
#RUN deluser --remove-home node \
RUN addgroup -S demo -g ${GROUP_ID} \
  && adduser -S -G demo -u ${USER_ID} demo \
  && mkdir -p ${WORK_DIR} ${WORK_DIR}/node_modules \
  && chown demo:demo ${WORK_DIR} -R

WORKDIR ${WORK_DIR}

ENV \
  TERM=xterm \
  MODE=${MODE}

# Provide entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN apk add --no-cache tini
ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh" ]

###################################
FROM base as dev-base
USER root
RUN apk --no-cache add make bash
RUN npm install pm2 -g

COPY --chown=demo:demo package.json ${WORK_DIR}
COPY --chown=demo:demo yarn.lock ${WORK_DIR}
RUN yarn install

COPY . .
USER demo

RUN yarn build:ci


# Local Development Image
###################################
FROM dev-base as development
EXPOSE 3000
EXPOSE 5001
CMD ["idle"]

# Test Image
###################################
FROM dev-base as test
EXPOSE 3000
EXPOSE 5001

CMD ["test"]

# Release Image Base
###################################
FROM dev-base as release-base

# Release Image
###################################
FROM dev-base as release
EXPOSE 3000
EXPOSE 5001

RUN yarn build:ci
CMD ["daemon"]

