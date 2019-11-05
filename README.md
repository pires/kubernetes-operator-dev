# kubernetes-operator-dev

I hacked this container image so that I can build operators from anywhere I can run a container on.

```console
docker run \
  -name dev \
  -it \
  -v /path/to/project:/workspace \
  -v /path/to/kubeconfig:/kubeconfig:ro \
  quay.io/pires/kubernetes-operator-dev:latest
```
