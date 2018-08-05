
#GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main -ldflags '-w -s' main.go

BIN=earnings-scheduler

GOOS=linux
GOARCH=amd64
CGO_ENABLED=0

GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOFLAGS=-ldflags '-w -s'
DOCKER=docker
DOCKERBUILD=$(DOCKER) build
DOCKERRUN=$(DOCKER) run
DOCKERPUSH=$(DOCKER) push
AWS=alex

GODEP=dep
NEWDEP=$(GODEP) ensure

AWSECR=848984447616.dkr.ecr.us-east-1.amazonaws.com/music-room

all: go-build docker-build docker-push clean

go-build:
	@echo "Golang build executable..."
	$(NEWDEP)
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=$(CGO_ENABLED) $(GOBUILD) -o $(BIN) $(GOFLAGS) main.go

docker-build:
	@echo "Docker build service..."
#	$(DOCKERBUILD) --no-cache -t $(BIN) .
	$(DOCKERBUILD) --no-cache -t $(BIN) .

docker-push:
	@echo "Push Docker image to AWS ECR..."
	docker tag $(BIN) 848984447616.dkr.ecr.us-east-1.amazonaws.com/music-room
	docker push 848984447616.dkr.ecr.us-east-1.amazonaws.com/music-room
	#aws ecr get-login --no-include-email --region us-east-1 | sed 's|https://||'
#	@aws --profile $(AWS) --region eu-west-1 ecr get-login --no-include-email | sed 's|https://||'
	#$(DOCKERPUSH) $(AWSECR)/$(BIN)

run:
	@echo "Docker run service..."
	$(DOCKERRUN) \
	--rm \
	-dt \
	-p 8001:8001 \
	--name=$(BIN) \
	$(BIN)

clean:
	@echo "Clean"
	$(GOCLEAN)
	rm -f $(BINARY)