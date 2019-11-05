FROM ubuntu:18.04

# default the go proxy
ARG goproxy=https://proxy.golang.org

# run this with docker build --build_arg $(go env GOPROXY) to override the goproxy
ENV GOPROXY=$goproxy
# Go stuff
ENV OS=linux
ENV ARCH=amd64
# versions
ENV KUBERNETES_VERSION=1.16.2
ENV KUBEBUILDER_VERSION=2.1.0

ENV KUBEBUILDER_ASSETS=/usr/local/kubebuilder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# install go, bazel
RUN apt-get update ; \
    apt-get install -y software-properties-common curl pkg-config zip g++ zlib1g-dev unzip python3 ; \
    add-apt-repository -y ppa:longsleep/golang-backports ; \
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list ; \
    curl https://bazel.build/bazel-release.pub.gpg | apt-key add - ; \
    apt-get update ; \
    apt-get install -y golang-go openjdk-11-jdk bazel ; \
    apt-get autoclean ; \
    rm -rf /var/lib/apt/lists/*

# install kubectl
RUN curl -L https://dl.k8s.io/v${KUBERNETES_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -xz ; \
    mv /tmp/kubernetes/client/bin/kubectl /usr/local/bin

# install kustomize
RUN curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases |\
    grep browser_download |\
    grep $OS |\
    cut -d '"' -f 4 |\
    grep /kustomize/v |\
    sort | tail -n 1 |\
    xargs curl -sL  | tar -xz ; \
    mv /tmp/kustomize /usr/local/bin

# install kubebuilder
RUN curl -sL https://go.kubebuilder.io/dl/${KUBEBUILDER_VERSION}/${OS}/${ARCH} | tar -xz ; \
    mv /tmp/kubebuilder_${KUBEBUILDER_VERSION}_${OS}_${ARCH} ${KUBEBUILDER_ASSETS} ; \
    ln -fs ${KUBEBUILDER_ASSETS}/bin/kubebuilder /usr/local/bin/kubebuilder

# must mount valid kubeconfig for Kubernetes cluster access
VOLUME /kubeconfig
ENV KUBECONFIG=/kubeconfig

# mount the project's workspace
VOLUME /workspace
WORKDIR /workspace
