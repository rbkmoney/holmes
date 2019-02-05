REBAR := $(shell which rebar3 2>/dev/null || which ./rebar3)
RELDIR := $(CURDIR)/scripts

.PHONY: all party_migration_script observer_cli

all: party_migration_script observer_cli

party_migration_script:
	$(MAKE) -C $@
	mkdir -p $(RELDIR)/hellgate
	cp $@/_build/default/bin/migration $(RELDIR)/hellgate/party-migration

observer_cli:
	cd $@ && $(REBAR) as inet6 escriptize
	mkdir -p $(RELDIR)
	cp $@/_build/inet6/bin/observer_cli $(RELDIR)/observer-cli
