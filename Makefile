# Makefile for rsync
SHELL := /bin/bash
SYNC_DIR = /tmp/
# SYNC_DIR=~/bin/Version5_ev1738/Dragon/msca/
REMOTE_SERV = doppler # boltzmann

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

copy_tmuxlog: ## cp tmuxlog files to remote
	scp -r scripts/tmuxlog*.sh $(REMOTE_SERV):~/bin/Version5_ev1738/Dragon/msca/

# ASSEMBLY_A
push-assembly-a: ## push ASSEMBLY_A
	rsync -avzP ./ASSEMBLY_A $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-a-dry: ## push dry ASSEMBLY_A
	rsync -anv ./ASSEMBLY_A $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-a: ## pull ASSEMBLY_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A .

pull-assembly-a-dry:  ## pull dry ASSEMBLY_A
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A . --delete --dry-run


# ASSEMBLY_B
push-assembly-b:
	rsync -avzP ./ASSEMBLY_B $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-b-dry:
	rsync -anv ./ASSEMBLY_B $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-b:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B .

pull-assembly-b-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B . --delete --dry-run


# ASSEMBLY_C
push-assembly-c:
	rsync -avzP ./ASSEMBLY_C $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-c-dry:
	rsync -anv ./ASSEMBLY_C $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-c:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C .

pull-assembly-c-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C . --delete --dry-run


# ASSEMBLY_D
push-assembly-d:
	rsync -avzP ./ASSEMBLY_D $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-d-dry:
	rsync -anv ./ASSEMBLY_D $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-d:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D .

pull-assembly-d-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D . --delete --dry-run


# ASSEMBLY_A_SHORT
push-assembly-a-short: ## push ASSEMBLY_A_SHORT
	rsync -avzP ./ASSEMBLY_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-a-short-dry: ## push dry ASSEMBLY_A_SHORT
	rsync -anv ./ASSEMBLY_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-a-short: ## pull ASSEMBLY_A_SHORT
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A_SHORT .

pull-assembly-a-short-dry:  ## pull dry ASSEMBLY_A_SHORT
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A_SHORT . --delete --dry-run


# ASSEMBLY_B_SHORT
push-assembly-b-short:
	rsync -avzP ./ASSEMBLY_B_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-b-short-dry:
	rsync -anv ./ASSEMBLY_B_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-b-short:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B_SHORT .

pull-assembly-b-short-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B_SHORT . --delete --dry-run


# ASSEMBLY_C_SHORT
push-assembly-c-short:
	rsync -avzP ./ASSEMBLY_C_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-c-short-dry:
	rsync -anv ./ASSEMBLY_C_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-c-short:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C_SHORT .

pull-assembly-c-short-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C_SHORT . --delete --dry-run


# ASSEMBLY_D_SHORT
push-assembly-d-short:
	rsync -avzP ./ASSEMBLY_D_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

push-assembly-d-short-dry:
	rsync -anv ./ASSEMBLY_D_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-assembly-d-short:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D_SHORT .

pull-assembly-d-short-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D_SHORT . --delete --dry-run

# PIN_A
push-pin-a: ## push PIN_A
	rsync -avzP ./PIN_A $(REMOTE_SERV):$(SYNC_DIR) --delete

push-pin-a-dry: ## push dry PIN_A
	rsync -anv ./PIN_A $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-pin-a: ## pull PIN_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_A . 

pull-pin-a-dry: ## pull dry PIN_A
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/PIN_A . --delete --dry-run


# PIN_B
push-pin-b:
	rsync -avzP ./PIN_B $(REMOTE_SERV):$(SYNC_DIR) --delete

push-pin-b-dry:
	rsync -anv ./PIN_B $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-pin-b:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_B . 

pull-pin-b-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/PIN_B . --delete --dry-run


# PIN_C
push-pin-c:
	rsync -avzP ./PIN_C $(REMOTE_SERV):$(SYNC_DIR) --delete

push-pin-c-dry:
	rsync -anv ./PIN_C $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-pin-c:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_C . 

pull-pin-c-dry:
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/PIN_C . --delete --dry-run


# PIN_A_SHORT
push-pin-short: ## push PIN_A_SHORT
	rsync -avzP ./PIN_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

push-pin-short-dry: ## push PIN_A_SHORT dry
	rsync -anv ./PIN_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --delete

pull-pin-short: ## pull PIN_A_SHORT
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_A_SHORT . 

pull-pin-short-dry: ## pull PIN_A_SHORT dry
	rsync -av $(REMOTE_SERV):$(SYNC_DIR)/PIN_A_SHORT . --delete --dry-run
