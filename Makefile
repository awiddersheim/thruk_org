GEM=gem1.9.1
GEM_HOME=.gem
JEKYLL=.gem/bin/jekyll
TESTPORT=4001

quick: .gem
	GEM_HOME=$(GEM_HOME) NOCLEAN=1 $(JEKYLL) build --trace --limit_posts=5 --no-watch

build: .gem
	GEM_HOME=$(GEM_HOME) $(JEKYLL) build --trace

server: .gem
	GEM_HOME=$(GEM_HOME) $(JEKYLL) serve --host=\* --trace --watch

.gem:
	# apt-get install libmagickcore-dev libmagickwand-dev
	GEM_HOME=$(GEM_HOME) $(GEM) install jekyll
	GEM_HOME=$(GEM_HOME) $(GEM) install rmagick
	GEM_HOME=$(GEM_HOME) $(GEM) install jekyll-asciidoc --pre

test: .gem
	GEM_HOME=$(GEM_HOME) NOCLEAN=1 $(JEKYLL) serve --port=$(TESTPORT) & SPID=$$!;  \
		for i in $$(seq 100); do if lsof -i:$(TESTPORT) >/dev/null 2>&1; then break; else sleep 0.3; fi done; \
		TESTEXPECT=Thruk TESTTARGET=http://localhost:$(TESTPORT) PERL_DL_NONLAZY=1 perl -MExtUtils::Command::MM -e "test_harness(0)" t/*.t; \
		RC=$$?; \
		kill -9 $$SPID; \
		exit $$RC

localtest: _site
	TESTEXPECT=Thruk TESTTARGET=file://$(shell pwd)/_site/ PERL_DL_NONLAZY=1 perl -MExtUtils::Command::MM -e "test_harness(0)" t/*.t

api_update:
	./api_update.pl /home/thruk/Thruk/ /home/thruk/thruk_libs/local-lib/dest/lib/perl5/
