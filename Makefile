# Makefile for rsync
SHELL := /bin/bash
SYNC_DIR = /tmp/
# SYNC_DIR=~/bin/Version5_ev1738/Dragon/msca/
REMOTE_SERV = doppler
# REMOTE_SERV = boltzmann

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

copy_tmuxlog: ## cp tmuxlog files to remote
	scp -r scripts/tmuxlog*.sh $(REMOTE_SERV):~/bin/Version5_ev1738/Dragon/msca/

# Serpent
push-serpent: ## push serpent inputs
	rsync -avzP ./Serpent $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-serpent-dry: ## push serpent inputs dry
	rsync -anv ./Serpent $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-serpent: ## pull serpent data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/Serpent .

pull-serpent-dry: ## pull dry serpent data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/Serpent .


# Dragon
push-assembly-all:
	rsync -avzP ./Dragon/ASSEMBLY_*_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-all-dry:
	rsync -anv ./Dragon/ASSEMBLY_*_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-all:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_* ./Dragon

pull-assembly-all-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_* ./Dragon

# ASSEMBLY_A
push-assembly-a: ## push ASSEMBLY_A
	rsync -avzP ./Dragon/ASSEMBLY_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-a-dry: ## push dry ASSEMBLY_A
	rsync -anv ./Dragon/ASSEMBLY_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-a: ## pull ASSEMBLY_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A ./Dragon

pull-assembly-a-dry:  ## pull dry ASSEMBLY_A
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A ./Dragon


# ASSEMBLY_B
push-assembly-b:
	rsync -avzP ./Dragon/ASSEMBLY_B $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-b-dry:
	rsync -anv ./Dragon/ASSEMBLY_B $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-b:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B ./Dragon

pull-assembly-b-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B ./Drago


# ASSEMBLY_C
push-assembly-c:
	rsync -avzP ./Dragon/ASSEMBLY_C $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-c-dry:
	rsync -anv ./Dragon/ASSEMBLY_C $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-c:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C ./Dragon

pull-assembly-c-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C ./Dragon


# ASSEMBLY_D
push-assembly-d:
	rsync -avzP ./Dragon/ASSEMBLY_D $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-d-dry:
	rsync -anv ./Dragon/ASSEMBLY_D $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-d:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D ./Dragon

pull-assembly-d-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D ./Dragon


# ASSEMBLY_A_SHORT
push-assembly-a-short: ## push ASSEMBLY_A_SHORT
	rsync -avzP ./Dragon/ASSEMBLY_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-a-short-dry: ## push dry ASSEMBLY_A_SHORT
	rsync -anv ./Dragon/ASSEMBLY_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-a-short: ## pull ASSEMBLY_A_SHORT
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A_SHORT ./Dragon

pull-assembly-a-short-dry:  ## pull dry ASSEMBLY_A_SHORT
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A_SHORT ./Dragon


# ASSEMBLY_B_SHORT
push-assembly-b-short:
	rsync -avzP ./Dragon/ASSEMBLY_B_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-b-short-dry:
	rsync -anv ./Dragon/ASSEMBLY_B_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-b-short:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B_SHORT ./Dragon

pull-assembly-b-short-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_B_SHORT ./Dragon


# ASSEMBLY_C_SHORT
push-assembly-c-short:
	rsync -avzP ./Dragon/ASSEMBLY_C_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-c-short-dry:
	rsync -anv ./Dragon/ASSEMBLY_C_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-c-short:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C_SHORT ./Dragon

pull-assembly-c-short-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_C_SHORT ./Dragon


# ASSEMBLY_D_SHORT
push-assembly-d-short:
	rsync -avzP ./Dragon/ASSEMBLY_D_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-d-short-dry:
	rsync -anv ./Dragon/ASSEMBLY_D_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-d-short:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D_SHORT ./Dragon

pull-assembly-d-short-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_D_SHORT ./Dragon

# PIN_A
push-pin-a: ## push PIN_A
	rsync -avzP ./Dragon/PIN_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-a-dry: ## push dry PIN_A
	rsync -anv ./Dragon/PIN_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-a: ## pull PIN_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_A ./Dragon

pull-pin-a-dry: ## pull dry PIN_A
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_A ./Dragon


# PIN_B
push-pin-b:
	rsync -avzP ./Dragon/PIN_B $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-b-dry:
	rsync -anv ./Dragon/PIN_B $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-b:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_B ./Dragon

pull-pin-b-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_B ./Dragon


# PIN_C
push-pin-c:
	rsync -avzP ./Dragon/PIN_C $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-c-dry:
	rsync -anv ./Dragon/PIN_C $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-c:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_C ./Dragon

pull-pin-c-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_C ./Dragon


# PIN_A_SHORT
push-pin-short: ## push PIN_A_SHORT
	rsync -avzP ./Dragon/PIN_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-short-dry: ## push PIN_A_SHORT dry
	rsync -anv ./Dragon/PIN_A_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-short: ## pull PIN_A_SHORT
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_A_SHORT ./Dragon

pull-pin-short-dry: ## pull PIN_A_SHORT dry
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_A_SHORT ./Dragon
