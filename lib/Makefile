REBAR := $(shell which rebar3 2>/dev/null || which ./rebar3)

.PHONY: all party_migration_script observer_cli

all: party_migration_script observer_cli

party_migration_script:
	$(MAKE) -C $@
	cp $@/_build/default/bin/migration $(RELDIR)/hellgate/party-migration

observer_cli:
	cd $@ && $(REBAR) escriptize
	cp $@/_build/default/bin/observer_cli $(RELDIR)/observer-cli
