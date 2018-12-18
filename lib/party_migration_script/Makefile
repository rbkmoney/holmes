REBAR = $(shell which rebar3 2>/dev/null || which ./rebar3)

default: migration

.PHONY: all compile dialyze clean distclean migration

compile:
	$(REBAR) compile

dialyze:
	$(REBAR) dialyzer

migration:
	$(REBAR) escriptize

clean:
	$(REBAR) clean

distclean: clean
	rm -rf _build
