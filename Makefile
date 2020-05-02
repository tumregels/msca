# Makefile for rsync
SHELL := /bin/bash
VERSION = 0.0.2

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# CGN_ASSEMBLY_A
.PHONY: push-assembly-a
push-assembly-a: ## push CGN_ASSEMBLY_A
	rsync -avzP ./CGN_ASSEMBLY_A boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: push-assembly-a-dry
push-assembly-a-dry: ## push dry CGN_ASSEMBLY_A
	rsync -anv ./CGN_ASSEMBLY_A boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: pull-assembly-a
pull-assembly-a: ## pull CGN_ASSEMBLY_A
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_ASSEMBLY_A .

.PHONY: pull-assembly-a-dry
pull-assembly-a-dry:  ## pull dry CGN_ASSEMBLY_A
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_ASSEMBLY_A . --delete --dry-run


# CGN_ASSEMBLY_B
.PHONY: push-assembly-b
push-assembly-b:
	rsync -avzP ./CGN_ASSEMBLY_B boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: push-assembly-b-dry
push-assembly-b-dry:
	rsync -anv ./CGN_ASSEMBLY_B boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: pull-assembly-b
pull-assembly-b:
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_ASSEMBLY_B .

.PHONY: pull-assembly-b-dry
pull-assembly-b-dry:
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_ASSEMBLY_B . --delete --dry-run


# CGN_ASSEMBLY_C
.PHONY: push-assembly-c
push-assembly-c:
	rsync -avzP ./CGN_ASSEMBLY_C boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: push-assembly-c-dry
push-assembly-c-dry:
	rsync -anv ./CGN_ASSEMBLY_C boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: pull-assembly-c
pull-assembly-c:
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_ASSEMBLY_C .

.PHONY: pull-assembly-c-dry
pull-assembly-c-dry:
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_ASSEMBLY_C . --delete --dry-run


# CGN_PIN_A
.PHONY: push-pin-a
push-pin-a:
	rsync -avzP ./CGN_PIN_A boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: push-pin-a-dry
push-pin-a-dry:
	rsync -anv ./CGN_PIN_A boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: pull-pin-a
pull-pin-a:
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_PIN_A . 

.PHONY: pull-pin-a-dry
pull-pin-a-dry:
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_PIN_A . --delete --dry-run


# CGN_PIN_B
.PHONY: push-pin-b
push-pin-b:
	rsync -avzP ./CGN_PIN_B boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: push-pin-b-dry
push-pin-b-dry:
	rsync -anv ./CGN_PIN_B boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: pull-pin-b
pull-pin-b:
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_PIN_B . 

.PHONY: pull-pin-b-dry
pull-pin-b-dry:
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_PIN_B . --delete --dry-run


# CGN_PIN_C
.PHONY: push-pin-c
push-pin-c:
	rsync -avzP ./CGN_PIN_C boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: push-pin-c-dry
push-pin-c-dry:
	rsync -anv ./CGN_PIN_C boltzmann:~/bin/Version5_ev1738/Dragon/msca/ --delete

.PHONY: pull-pin-c
pull-pin-c:
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_PIN_C . 

.PHONY: pull-pin-c-dry
pull-pin-c-dry:
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/CGN_PIN_C . --delete --dry-run
