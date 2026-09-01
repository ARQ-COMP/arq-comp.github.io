# Local helpers. There is no CI on this repository by design -- `make check`
# is the check that would otherwise have run there. Worth running before a
# push: a failed Pages build does not publish, it just leaves the site stale.

.PHONY: serve build check clean

## Preview the site at http://127.0.0.1:4000
serve:
	bundle exec jekyll serve

## Build once into _site/
build:
	bundle exec jekyll build

## What to run before pushing.
check:
	bundle exec jekyll build --strict_front_matter
	@test -s _site/index.html || { echo "FAIL: no _site/index.html was generated"; exit 1; }
	@echo "OK: the site builds and the homepage was generated"

clean:
	rm -rf _site .jekyll-cache
