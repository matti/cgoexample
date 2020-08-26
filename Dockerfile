FROM gcc as cbuilder

WORKDIR /src
COPY libperson .
RUN make

FROM golang as gobuilder

WORKDIR /build

COPY go.mod .
COPY cmd cmd

COPY --from=cbuilder /src/person.h /usr/include
COPY --from=cbuilder /src/libperson.a /usr/lib

RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -ldflags '-extldflags "-static"' -o /gorson ./cmd/gorson

FROM scratch

COPY --from=gobuilder /gorson /
ENTRYPOINT [ "/gorson" ]
