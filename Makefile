SHELL = /bin/bash


OS := $(shell uname)
ifeq ($(OS), Linux)
	dc = sudo docker-compose
	su-rm = sudo rm
	xargs-seperator = -d '\n'
else
	dc = docker-compose
	su-rm = rm
	xargs-seperator = -0
endif


define newline


endef

EMIT = echo -e '$(subst $(newline),\n,$(1))'


.PHONY: docker-images
docker-images: 
	$(dc) build $(s)

.PHONY: start
start: 
	$(dc) up $(s) || $(MAKE) stop s=$(s)

.PHONY: stop
stop: 
	$(dc) stop $(s)


.PHONY: tear-it-all-down
tear-it-all-down:
	@echo "### Tearing it all down... ###"
	$(MAKE) clean-docker-deeply
	$(MAKE) clean-esy-build

.PHONY: clean-docker-containers
clean-docker-containers:
	$(dc) down --volumes || exit 0

.PHONY: clean-docker-deeply
clean-docker-deeply:
	$(dc) down --volumes --rmi all || exit 0
	$(su-rm) -rf .docker 
	rm -f esy


.PHONY: shell
shell: 
	$(dc) exec $(s) bash


define ESY_FOR_HOST
#!/bin/bash

$(dc) --file="$(shell pwd)/docker-compose.yml" \
	exec --workdir="/app" app esy "$$@"
endef

esy: 
	@$(call EMIT,$(ESY_FOR_HOST)) > $(@)
	@chmod +x $(@)



app-make = $(dc) exec --workdir=/app app make

_esy: esy
	esy install

.PHONY: clean-esy-build
clean-esy-build: 
	$(su-rm) -rf _esy
	$(app-make) $@


.PHONY: main.exe
main.exe: 
	$(app-make) $@

.PHONY: rebuild
rebuild: 
	$(app-make) $@
	esy

.PHONY: run
run: 
	$(app-make) $@

# Build and run main.exe
.PHONY: brun
brun: rebuild run


.PHONY: follow-db-logs
follow-db-logs: 
	$(dc) exec db sh -c "tail -f /var/log/mysql/*.log"