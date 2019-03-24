DOCKER_IMAGE=mysql
DOCKER_NAMESPACE=nouchka
NAME=$(DOCKER_NAMESPACE)-$(DOCKER_IMAGE)
VERSION=0.1
DESCRIPTION=$(DOCKER_IMAGE) with docker in a package
URL=https://github.com/nouchka/docker-$(DOCKER_IMAGE)
VENDOR=katagena
MAINTAINER=Jean-Avit Promis <docker@katagena.com>
LICENSE=Apache License 2.0

prefix = /usr/local

.DEFAULT_GOAL := build

VERSIONS=5.5 5.6
DEBVERSIONS=5.6

deb:
	mkdir -p build/usr/sbin/
	cp -Rf bin/$(DOCKER_IMAGE) build/usr/sbin/
	cp bin/$(DOCKER_IMAGE) build/usr/sbin/mysqldump
	$(foreach version,$(DEBVERSIONS), cp bin/$(DOCKER_IMAGE) build/usr/sbin/$(DOCKER_IMAGE)$(version);)
	$(foreach version,$(DEBVERSIONS), cp bin/$(DOCKER_IMAGE) build/usr/sbin/mysqldump$(version);)

build-deb: deb
	rm -f $(NAME)_$(VERSION).$(TRAVIS_BUILD_NUMBER)_amd64.deb
	fpm -t deb -s dir -n $(NAME) -v $(VERSION).$(TRAVIS_BUILD_NUMBER) --description "$(DESCRIPTION)" -C build \
	--vendor "$(VENDOR)" -m "$(MAINTAINER)" --license "$(LICENSE)" --url $(URL) --deb-no-default-config-files \
	-d docker-ce \
	.
	rm -rf build/

push-deb: build-deb
	package_cloud push nouchka/home/ubuntu/xenial $(NAME)_*.deb

build-latest:
	$(MAKE) -s build-version VERSION=latest

build-version:
	@chmod +x ./hooks/build
	DOCKER_TAG=$(VERSION) IMAGE_NAME=$(DOCKER_NAMESPACE)/$(DOCKER_IMAGE):$(VERSION) ./hooks/build

.PHONY: build
build: build-latest
	$(foreach version,$(VERSIONS), $(MAKE) -s build-version VERSION=$(version);)

run:
	./bin/$(DOCKER_IMAGE)

check:
	docker run --rm -i hadolint/hadolint < Dockerfile

version:
	docker run --rm $(DOCKER_NAMESPACE)/$(DOCKER_IMAGE):$(VERSION) mysql -V

versions:
	$(foreach version,$(VERSIONS), $(MAKE) -s version VERSION=$(version);)

install:
	install bin/$(DOCKER_IMAGE) $(prefix)/bin
