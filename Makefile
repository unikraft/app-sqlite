UK_ROOT ?= $(PWD)/workdir/unikraft
UK_LIBS ?= $(PWD)/workdir/libs
UK_BUILD ?= $(PWD)/workdir/build
LIBS := $(UK_LIBS)/musl:$(UK_LIBS)/sqlite

all:
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) O=$(UK_BUILD)

$(MAKECMDGOALS):
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) O=$(UK_BUILD) $(MAKECMDGOALS)
