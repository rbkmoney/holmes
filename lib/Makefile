REBAR := $(shell which rebar3 2>/dev/null || which ./rebar3)

.PHONY: all party_migration_script observer_cli

all: party_migration_script

party_migration_script:
	$(MAKE) -C $@
	cp $@/_build/default/bin/migration $(RELDIR)/hellgate/party-migration
