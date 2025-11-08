BOOTSTRAP_VERSION=5.3.3
BOOTSTRAP_ICONS_VERSION=1.13.1

BOOTSTRAP_URL=https://github.com/twbs/bootstrap/releases/download/v${BOOTSTRAP_VERSION}/bootstrap-${BOOTSTRAP_VERSION}-dist.zip
BOOTSTRAP_ICONS_URL=https://github.com/twbs/icons/releases/download/v${BOOTSTRAP_ICONS_VERSION}/bootstrap-icons-${BOOTSTRAP_ICONS_VERSION}.zip
DEPENDS= \
	docs/js/bootstrap.bundle.min.js \
	docs/js/bootstrap.bundle.min.js.map \
	docs/css/bootstrap.min.css \
	docs/css/bootstrap.min.css.map \
	docs/fonts/bootstrap-icons.css

# Update dependencies, build container and start local web site
all: fetch
	${MAKE} up

up:
	docker compose up --build

build: fetch
	docker compose build

fetch: ${DEPENDS}

docs/js/bootstrap.bundle.min.js docs/js/bootstrap.bundle.min.js.map: _dl/bootstrap-${BOOTSTRAP_VERSION}-dist.zip docs/js
	cp -p _dl/bootstrap-${BOOTSTRAP_VERSION}-dist/js/bootstrap.bundle.min.js docs/js/bootstrap.bundle.min.js
	cp -p _dl/bootstrap-${BOOTSTRAP_VERSION}-dist/js/bootstrap.bundle.min.js.map docs/js/bootstrap.bundle.min.js.map

docs/css/bootstrap.min.css docs/css/bootstrap.min.css.map: _dl/bootstrap-${BOOTSTRAP_VERSION}-dist.zip docs/css
	cp -p _dl/bootstrap-${BOOTSTRAP_VERSION}-dist/css/bootstrap.min.css docs/css/bootstrap.min.css
	cp -p _dl/bootstrap-${BOOTSTRAP_VERSION}-dist/css/bootstrap.min.css.map docs/css/bootstrap.min.css.map

_dl/bootstrap-${BOOTSTRAP_VERSION}-dist.zip: _dl
	cd _dl && umask 0 && \
		wget -N -q ${BOOTSTRAP_URL} && \
		unzip -q -o bootstrap-${BOOTSTRAP_VERSION}-dist.zip

_dl/bootstrap-icons-${BOOTSTRAP_ICONS_VERSION}.zip: _dl
	cd _dl && umask 0 && \
		wget -N -q ${BOOTSTRAP_ICONS_URL}

docs/fonts/bootstrap-icons.css: _dl/bootstrap-icons-${BOOTSTRAP_ICONS_VERSION}.zip docs/fonts
	cd docs/fonts && umask 0 && \
		unzip -j -q -o ../../_dl/bootstrap-icons-${BOOTSTRAP_ICONS_VERSION}.zip && \
		mv *.svg *.woff* fonts

_dl:
	mkdir _dl

docs/js:
	mkdir -p docs/js

docs/css:
	mkdir -p docs/css

docs/fonts:
	mkdir -p docs/fonts/fonts

clean:
	-rm -rf docs/_site _dl
	-rm -f ${DEPENDS}

true: ;
