# Makefile for rsync
SHELL := /bin/bash
SYNC_DIR = /tmp/
# SYNC_DIR=~/bin/msca/
REMOTE_SERV = doppler
# REMOTE_SERV = boltzmann

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

copy_tmuxlog: ## cp tmuxlog files to remote
	scp -r scripts/tmuxlog*.sh $(REMOTE_SERV):~/bin/Version5_ev1738/Dragon/msca/

export_conda_requirements: ## export/update conda requirements
	conda env export > requirements.yml

convert_m_files: ## convert serpent output files to mat files
	octave-cli --persist scripts/create_mat_files.m || true

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
	rsync -avzP ./Dragon/ASSBLY_? $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-all-dry:
	rsync -anv ./Dragon/ASSBLY_? $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-all:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSBLY_* ./Dragon

pull-assembly-all-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSBLY_* ./Dragon

push-pin-all:
	rsync -avzP ./Dragon/PIN_? $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-all-dry:
	rsync -anv ./Dragon/PIN_? $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-all:
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_? ./Dragon

pull-pin-all-dry:
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_? ./Dragon

# ASSEMBLY_A
push-assembly-a: ## push ASSEMBLY_A
	rsync -avzP ./Dragon/ASSEMBLY_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assembly-a-dry: ## push dry ASSEMBLY_A
	rsync -anv ./Dragon/ASSEMBLY_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assembly-a: ## pull ASSEMBLY_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A ./Dragon

pull-assembly-a-dry:  ## pull dry ASSEMBLY_A
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSEMBLY_A ./Dragon

# PIN_A
push-pin-a: ## push PIN_A
	rsync -avzP ./Dragon/PIN_A8 $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-a-dry: ## push dry PIN_A
	rsync -anv ./Dragon/PIN_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-a: ## pull PIN_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_A ./Dragon

pull-pin-a-dry: ## pull dry PIN_A
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_A ./Dragon
