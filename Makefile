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
push-dragon: ## push all dragon inputs
	rsync -avzP ./Dragon $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-dragon-dry: ## push all dragon inputs dry
	rsync -anv ./Dragon $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-dragon: ## pull all dragon inputs
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/Dragon .

pull-dragon-dry: ## pull all dragon inputs dry
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/Dragon .

# 1L
push-1L: ## push 1L_SHORT inputs
	rsync -avzP ./Dragon/1L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-1L-dry: ## push 1L_SHORT inputs dry
	rsync -anv ./Dragon/1L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-1L: ## pull 1L_SHORT data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/1L ./Dragon

pull-1L-dry: ## pull dry 1L_SHORT data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/1L ./Dragon

# 2L
push-2L: ## push 2L inputs
	rsync -avzP ./Dragon/2L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

push-2L-dry: ## push 2L inputs dry
	rsync -anv ./Dragon/2L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

pull-2L: ## pull 2L data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/2L ./Dragon

pull-2L-dry: ## pull dry 1L_LONG data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/2L ./Dragon

keff: ## extract keff data from *.result files using ripgrep
	rg -u -o -I '\|\+.*?(\d+\.\d+e.\d+)\s+Keff=\s+(\d+\.\d+e.\d+).*?$' -r '$1 $2' | cat > keff.txt

replace: ## replace string using ripgrep and sed
	rg -u 'ABC' -g '!Makefile' -l | xargs sed -i 's/ABC//g'

clean:  ## clean up project
	find . -type d -name __pycache__ -exec rm -r {} \+
	find . -type d -name .ipynb_checkpoints -exec rm -r {} \+
	find . -type d -name .mypy_cache -exec rm -r {} \+
