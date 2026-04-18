# mosquitto

Multi-arch (`linux/amd64`, `linux/arm64`) Docker image for the [Eclipse Mosquitto](https://mosquitto.org/) MQTT broker, built from source on Debian Trixie Slim. Primarily intended for Kubernetes deployments.

Images are published to `ghcr.io/daedaluz/mosquitto` and tagged by Mosquitto version.

## Features

- Built from the official Mosquitto git tag
- TLS support (OpenSSL)
- WebSocket support (built-in, port 9001)
- Async DNS via c-ares
- Multi-arch: `linux/amd64` and `linux/arm64`

## Usage

```sh
docker pull ghcr.io/daedaluz/mosquitto:2.1.2
```

```sh
docker run -p 1883:1883 -p 9001:9001 ghcr.io/daedaluz/mosquitto:2.1.2
```

## Build arguments

| Argument           | Default                                        | Description                  |
|--------------------|------------------------------------------------|------------------------------|
| `MOSQUITTO_TAG`    | `v2.1.2`                                       | Git tag to build from        |
| `MOSQUITTO_REPO`   | `https://github.com/eclipse/mosquitto.git`     | Git repository URL           |
| `DEBIAN_VERSION`   | `trixie-slim`                                  | Debian base image variant    |

```sh
docker build --build-arg MOSQUITTO_TAG=v2.1.2 -t mosquitto .
```

## Kubernetes

Manifests are provided in the [`kubernetes/`](kubernetes/) directory:

```
kubernetes/
├── configmap.yaml   # mosquitto.conf
├── pvc.yaml         # persistent storage for /var/lib/mosquitto
├── deployment.yaml  # mosquitto deployment
├── service.yaml     # LoadBalancer on ports 1883 (MQTT) and 9001 (WebSocket)
└── httproute.yaml   # Gateway API HTTPRoute for WebSocket ingress
```

Update `httproute.yaml` with your Gateway name and hostname before applying.

```sh
kubectl apply -f kubernetes/
```

## Configuration

The default configuration enables both MQTT (1883) and WebSocket (9001) listeners with anonymous access. Mount a custom `mosquitto.conf` via the ConfigMap to add authentication or TLS.
