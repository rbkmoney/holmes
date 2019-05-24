REBAR := $(shell which rebar3 2>/dev/null || which ./rebar3)
RELDIR := $(CURDIR)/scripts

.PHONY: all observer_cli

all: observer_cli

observer_cli:
	cd $@ && $(REBAR) as inet6 escriptize
	mkdir -p $(RELDIR)
	cp $@/_build/inet6/bin/observer_cli $(RELDIR)/observer-cli
