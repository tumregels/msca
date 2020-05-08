# Makefile for rsync
SHELL := /bin/bash
SYNC_DIR = /tmp/
# SYNC_DIR=~/bin/Version5_ev1738/Dragon/msca/

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


# ASSEMBLY_A
.PHONY: push-assembly-a
push-assembly-a: ## push ASSEMBLY_A
	rsync -avzP ./ASSEMBLY_A boltzmann:$(SYNC_DIR) --delete

.PHONY: push-assembly-a-dry
push-assembly-a-dry: ## push dry ASSEMBLY_A
	rsync -anv ./ASSEMBLY_A boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-assembly-a
pull-assembly-a: ## pull ASSEMBLY_A
	rsync -avzP boltzmann:$(SYNC_DIR)/ASSEMBLY_A .

.PHONY: pull-assembly-a-dry
pull-assembly-a-dry:  ## pull dry ASSEMBLY_A
	rsync -av boltzmann:$(SYNC_DIR)/ASSEMBLY_A . --delete --dry-run


# ASSEMBLY_B
.PHONY: push-assembly-b
push-assembly-b:
	rsync -avzP ./ASSEMBLY_B boltzmann:$(SYNC_DIR) --delete

.PHONY: push-assembly-b-dry
push-assembly-b-dry:
	rsync -anv ./ASSEMBLY_B boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-assembly-b
pull-assembly-b:
	rsync -avzP boltzmann:$(SYNC_DIR)/ASSEMBLY_B .

.PHONY: pull-assembly-b-dry
pull-assembly-b-dry:
	rsync -av boltzmann:$(SYNC_DIR)/ASSEMBLY_B . --delete --dry-run


# ASSEMBLY_C
.PHONY: push-assembly-c
push-assembly-c:
	rsync -avzP ./ASSEMBLY_C boltzmann:$(SYNC_DIR) --delete

.PHONY: push-assembly-c-dry
push-assembly-c-dry:
	rsync -anv ./ASSEMBLY_C boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-assembly-c
pull-assembly-c:
	rsync -avzP boltzmann:$(SYNC_DIR)/ASSEMBLY_C .

.PHONY: pull-assembly-c-dry
pull-assembly-c-dry:
	rsync -av boltzmann:$(SYNC_DIR)/ASSEMBLY_C . --delete --dry-run


# ASSEMBLY_D
.PHONY: push-assembly-d
push-assembly-d:
	rsync -avzP ./ASSEMBLY_D boltzmann:$(SYNC_DIR) --delete

.PHONY: push-assembly-d-dry
push-assembly-d-dry:
	rsync -anv ./ASSEMBLY_D boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-assembly-d
pull-assembly-d:
	rsync -avzP boltzmann:$(SYNC_DIR)/ASSEMBLY_D .

.PHONY: pull-assembly-d-dry
pull-assembly-d-dry:
	rsync -av boltzmann:$(SYNC_DIR)/ASSEMBLY_D . --delete --dry-run


# PIN_A
.PHONY: push-pin-a
push-pin-a: ## push PIN_A
	rsync -avzP ./PIN_A boltzmann:$(SYNC_DIR) --delete

.PHONY: push-pin-a-dry
push-pin-a-dry: ## push dry PIN_A
	rsync -anv ./PIN_A boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-pin-a
pull-pin-a: ## pull PIN_A
	rsync -avzP boltzmann:$(SYNC_DIR)/PIN_A . 

.PHONY: pull-pin-a-dry
pull-pin-a-dry: ## pull dry PIN_A
	rsync -av boltzmann:$(SYNC_DIR)/PIN_A . --delete --dry-run


# PIN_B
.PHONY: push-pin-b
push-pin-b:
	rsync -avzP ./PIN_B boltzmann:$(SYNC_DIR) --delete

.PHONY: push-pin-b-dry
push-pin-b-dry:
	rsync -anv ./PIN_B boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-pin-b
pull-pin-b:
	rsync -avzP boltzmann:$(SYNC_DIR)/PIN_B . 

.PHONY: pull-pin-b-dry
pull-pin-b-dry:
	rsync -av boltzmann:$(SYNC_DIR)/PIN_B . --delete --dry-run


# PIN_C
.PHONY: push-pin-c
push-pin-c:
	rsync -avzP ./PIN_C boltzmann:$(SYNC_DIR) --delete

.PHONY: push-pin-c-dry
push-pin-c-dry:
	rsync -anv ./PIN_C boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-pin-c
pull-pin-c:
	rsync -avzP boltzmann:$(SYNC_DIR)/PIN_C . 

.PHONY: pull-pin-c-dry
pull-pin-c-dry:
	rsync -av boltzmann:$(SYNC_DIR)/PIN_C . --delete --dry-run


# PIN_A_SHORT
.PHONY: push-pin-short
push-pin-short: ## push PIN_A_SHORT
	rsync -avzP ./PIN_A_SHORT boltzmann:$(SYNC_DIR) --delete

.PHONY: push-pin-short-dry
push-pin-short-dry: ## push PIN_A_SHORT dry
	rsync -anv ./PIN_A_SHORT boltzmann:$(SYNC_DIR) --delete

.PHONY: pull-pin-short
pull-pin-short: ## pull PIN_A_SHORT
	rsync -avzP boltzmann:$(SYNC_DIR)/PIN_A_SHORT . 

.PHONY: pull-pin-short-dry
pull-pin-short-dry: ## pull PIN_A_SHORT dry
	rsync -av boltzmann:$(SYNC_DIR)/PIN_A_SHORT . --delete --dry-run
