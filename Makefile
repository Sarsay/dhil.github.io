all: build

SITE=site

build: site
	./$(SITE) build

rebuild: site
	./$(SITE) rebuild

site: site.hs
	ghc --make -threaded site.hs

new:
	echo "Not yet implemented"

publish: build
	git add *
	git commit -m "Added new content"
	git push origin source
	cp -r _site/* _build/
	cd _build
	git add *
	git commit -m "Compiled new content"
	git push origin master

preview: build
	./$(SITE) watch

check: build
	./$(SITE) check

clean: site
	./$(SITE) clean
	rm -f $(SITE)

.PHONY: all build new publish preview clean check
