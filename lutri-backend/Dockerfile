FROM alpine:latest

COPY ./static/ ./static
COPY ./config.yml ./config.yml
COPY ./build/lutri-backend ./lutri-backend

EXPOSE 8080

CMD ["./lutri-backend"]


# # on windows I couldn't use the cross-compiled image for some reason

# FROM golang:1.14-alpine AS build

# WORKDIR /src/
# COPY . /src/

# RUN CGO_ENABLED=0 go build -o /lutri-backend


# FROM scratch

# COPY --from=build /lutri-backend /lutri-backend
# COPY ./static/ ./static
# COPY ./config.yml ./config.yml

# EXPOSE 8080

# ENTRYPOINT ["/lutri-backend"]
