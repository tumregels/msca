SHELL := /bin/bash
.DEFAULT_GOAL := help

SYNC_DIR = /tmp/
# SYNC_DIR=~/bin/msca/
REMOTE_SERV = doppler
# REMOTE_SERV = boltzmann

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-0-9]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

copy_tmuxlog: ## cp tmuxlog files to remote
	rsync -avzP ./scripts $(REMOTE_SERV):~/bin/

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

# ASSBLY_D
push-assbly-d: ## push ASSBLY_D
	rsync -avzP ./Dragon/ASSBLY_D $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-assbly-d-dry: ## push dry ASSBLY_A
	rsync -anv ./Dragon/ASSBLY_D $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-assbly-d: ## pull ASSBLY_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/ASSBLY_D ./Dragon --exclude '_*'

pull-assbly-d-dry:  ## pull dry ASSBLY_A
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/ASSBLY_D ./Dragon --exclude '_*'

# PIN_A
push-pin-a: ## push PIN_A
	rsync -avzP ./Dragon/PIN_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-pin-a-dry: ## push dry PIN_A
	rsync -anv ./Dragon/PIN_A $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-pin-a: ## pull PIN_A
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/PIN_A ./Dragon

pull-pin-a-dry: ## pull dry PIN_A
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/PIN_A ./Dragon


# 1L_SHORT
push-1L_SHORT: ## push 1L_SHORT inputs
	rsync -avzP ./Dragon/1L_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-1L_SHORT-dry: ## push 1L_SHORT inputs dry
	rsync -anv ./Dragon/1L_SHORT $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-1L_SHORT: ## pull 1L_SHORT data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/1L_SHORT ./Dragon

pull-1L_SHORT-dry: ## pull dry 1L_SHORT data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/1L_SHORT ./Dragon


# 1L_LONG
push-1L_LONG: ## push 1L_LONG inputs
	rsync -avzP ./Dragon/1L_LONG $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-1L_LONG-dry: ## push 1L_LONG inputs dry
	rsync -anv ./Dragon/1L_LONG $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-1L_LONG: ## pull 1L_LONG data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/1L_LONG ./Dragon

pull-1L_LONG-dry: ## pull dry 1L_LONG data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/1L_LONG ./Dragon


clean:  ## clean up project
	find . -type d -name __pycache__ -exec rm -r {} \+
	find . -type d -name .ipynb_checkpoints -exec rm -r {} \+
	find . -type d -name .mypy_cache -exec rm -r {} \+
