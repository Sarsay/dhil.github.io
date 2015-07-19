all: build

SITE=site

build: site
	./$(SITE) build

rebuild: site
	./$(SITE) rebuild

site: site.hs
	ghc --make -threaded site.hs

new:
	@echo -n "Enter blog post title> " ; \
	read title ; \
	echo "$$(date '+%Y-%m-%d')-$$title.html"

publish: build
	git add --ignore-errors posts/\*.md templates/\*.html site.hs README.md LICENSE index.html 404.html static/* images/* about.md
	git commit -m "Added new content"
	git push origin source
	cp -r _site/* _build/
	cp README.md LICENSE _build/
	cd _build; \
	git add --ignore-errors * ; \
	git commit -m "Compiled blog" ; \
	git push origin master

preview: build
	./$(SITE) watch

check: build
	./$(SITE) check

clean: site
	./$(SITE) clean
	rm -f $(SITE)

.PHONY: all build new publish preview clean check
