# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#FROM golang:1.19-buster AS build
#FROM golang:1.22-alpine3.19 AS builder
FROM --platform=linux/amd64 golang:1.22.2-bullseye AS builder

#RUN go get github.com/gin-gonic/gin@latest
#RUN go log
#RUN go net/http
#ENV GO111MODULE=on
#ENV GOFLAGS=-mod=vendor


WORKDIR /app
COPY ./.env ./
#COPY ./go.mod ./go.sum ./main.go ./

COPY . ./
RUN ls /app

RUN go mod download 
#RUN go mod verify
#COPY . ./

RUN ls /app

# go mod verify

#ENV GO111MODULE=on
#ENV GOFLAGS=-mod=vendor
#ENV CGO_ENABLED=0 
#ENV GOOS=linux
#RUN CGO_ENABLED=0 GOOS=linux go build -v -o gin-service .
#CMD [ "go","buid","-v","-o","/app/gin-service","." ]
#CGO_ENABLED=0 GOOS=linux
ENV GOCACHE=/root/.cache/go-build

RUN --mount=type=cache,target="/root/.cache/go-build" go build -v -o /app/gin-service ./...


FROM gcr.io/distroless/base-debian10 AS build-release-stage
#FROM alpine:3.19
# Deploy the application binary into a lean image
#FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /app

COPY --from=builder /app/gin-service ./gin-service
COPY --from=builder /app/.env ./.env
#COPY --from=builder "$APP_HOME"/mathapp $APP_HOME
#ENV PORT=8079
#EXPOSE ${PORT}

USER nonroot:nonroot
#RUN chmod a+x ./gin-service
#CMD ["/app/gin-service"]
#CMD [ "touch","./.env" ]
# RUN cat << EOF > .env \
# port=8080 \
# EOF
ENV API_TOKEN=1234
#ENTRYPOINT ["/app/gin-service"]
#RUN /app/gin-service
CMD [ "/app/gin-service" ]