.PHONY: all get-deps clean compile run eunit check check-eunit doc hex-publish rebar3-install

#REBAR=$(shell which rebar3 || echo ./rebar3)

CHECK_FILES=\
	ebin/*.beam

CHECK_EUNIT_FILES=\
	.eunit/*.beam

all: compile

clean:
	@$(REBAR) clean

compile:
	@$(REBAR) compile

run:
	$(REBAR) shell

check_warnings:
	@$(REBAR) as warnings compile

warnings:
ifeq ($(REBAR_VSN),2)
	@WARNINGS_AS_ERRORS=true $(REBAR) compile
	@AWS_DEFAULT_REGION=us-east-1 WARNINGS_AS_ERRORS=true $(REBAR) compile_only=true eunit
else
	@$(REBAR) as test compile
endif

eunit:
ifeq ($(REBAR_VSN),2)
	$(MAKE) compile
	@AWS_DEFAULT_REGION=us-east-1 $(REBAR) eunit skip_deps=true
else
	@AWS_DEFAULT_REGION=us-east-1 ERL_FLAGS="-config $(PWD)/eunit" $(REBAR) eunit
endif

.dialyzer_plt:
	dialyzer --build_plt -r _build/default \
		--apps erts kernel stdlib inets crypto public_key ssl xmerl \
		--fullpath \
		--output_plt .dialyzer_plt

check:
ifeq ($(REBAR_VSN),2)
	$(MAKE) compile
	@AWS_DEFAULT_REGION=us-east-1 $(REBAR) compile_only=true eunit
	$(MAKE) .dialyzer_plt
	dialyzer --no_check_plt --fullpath \
		$(CHECK_EUNIT_FILES) \
		-I include \
		--plt .dialyzer_plt
else
	@$(REBAR) as test dialyzer
endif

doc:
	@$(REBAR) edoc

hex-publish:
	@$(REBAR) hex publish

rebar3-install:
	wget https://s3.amazonaws.com/rebar3/rebar3
	chmod a+x rebar3
