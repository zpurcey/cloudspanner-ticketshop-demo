
PACKAGE           := spannerdemo-dashboard
GOOS              := linux
DATE              := $(shell TZ=UTC date +%FT%T)Z
VERSION           := $(shell git describe --always)
STATICSDIR        := static
PROJECT           ?= $(shell gcloud config list --format 'value(core.project)')
GCR               ?= gcr.io
DOCKER_FILE       := Dockerfile.$(GOOS)
SRCS              := $(shell find . -type f -name '*.go' -not -path "./vendor/*")
LDFLAGS           := '-X main.version=$(VERSION) -X main.build=$(DATE)'
$(PACKAGE): $(SRCS) $(STATICSDIR)
        go build -o $@ -ldflags $(LDFLAGS) $(SRC)
.PHONY: container push-gcr
all: container push-gcr
container: $(SRCS) $(DOCKER_FILE) $(STATICSDIR)
        # builds the binary and packages it into an alpine container
        docker build --build-arg ldflags=$(LDFLAGS) --build-arg package=$(PACKAGE) \
        --build-arg goos=$(GOOS) -t $(PACKAGE):$(VERSION) -f $(DOCKER_FILE) .
push-gcr: container
        # push to google cloud container registry
        docker tag $(PACKAGE):$(VERSION) $(GCR)/$(PROJECT)/$(PACKAGE):$(VERSION)
        docker tag $(PACKAGE):$(VERSION) $(GCR)/$(PROJECT)/$(PACKAGE):latest
        gcloud docker -- push $(GCR)/$(PROJECT)/$(PACKAGE):$(VERSION)
        gcloud docker -- push $(GCR)/$(PROJECT)/$(PACKAGE):latest
k8s:
        #redeploy dashboard
        kubectl --context spannerdemo-us-01 scale --replicas=0 deployment/spannerdemo-dashboard
        kubectl --context spannerdemo-us-01 scale --replicas=1 deployment/spannerdemo-dashboard

