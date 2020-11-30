SHELL := /bin/bash
.DEFAULT_GOAL := help

SYNC_DIR = /tmp/
REMOTE_SERV = doppler
# REMOTE_SERV = boltzmann

.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-0-9]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: create-environment
create-environment: ## create conda environment
	conda env create --name msca --file requirements.yml

.PHONY: process-iso-dens
process-iso-dens: # process isotopic densities
	cd src/iso_parser && matlab -nodisplay -nodesktop -r "run('process_iso_dens.m');exit;"

.PHONY: plot-burnup-vs-keff
plot-burnup-vs-keff: ## plot burnup vs keff
	cd src/iso_parser && matlab -nodisplay -nodesktop -r "run('plot_burnup_vs_keff.m');exit;"

.PHONY: plot-iso-pin-data
plot-iso-pin-data: ## plot isotopic densities for pin calculations
	cd src/iso_parser && \
	matlab -nodisplay -nodesktop -r "run('plot_isotopes_pin_bench_norm.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('plot_isotopes_pin_bench_rings.m');exit;"

.PHONY: plot-iso-assbly-data
plot-iso-assbly-data: ## plot isotopic densities for assembly calculations
	cd src/iso_parser && \
	matlab -nodisplay -nodesktop -r "run('plot_isotopes_assbly_bench_norm.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('plot_isotopes_assbly_bench_rings.m');exit;"

.PHONY: plot-iso-assbly-rings
plot-iso-assbly-rings: ## plot relative errors of iso density in all rings of assembly pins (30min)
	cd src/iso_parser && \
	matlab -nodisplay -nodesktop -r "run('plot_isotopes_assbly_bench_rings_all_pins.m');exit;"

.PHONY: process-fc-rates
process-fc-rates: ## process fission/capture rates (50min)
	cd src/fc_rate && \
	matlab -nodisplay -nodesktop -r "run('process_a_1l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_a_2l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_b_1l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_b_2l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_c_1l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_c_2l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_d_1l.m');exit;" && \
	matlab -nodisplay -nodesktop -r "run('process_d_2l.m');exit;"

.PHONY: plot-fc-data
plot-fc-data: ## plot heatmaps of fission and capture reaction rates
	PYTHONPATH=. python3 analysex/mapper/parse_fmap_errors.py && \
	PYTHONPATH=. python3 analysex/mapper/plot_assbly_maps.py && \
	PYTHONPATH=. python3 analysex/mapper/plot_fmap_errors.py

# helper targets

.PHONY: copy-tmuxlog
copy-tmuxlog: ## cp tmuxlog files to remote
	rsync -avzP ./scripts $(REMOTE_SERV):~/bin/

.PHONY: export-conda-requirements
export-conda-requirements: ## export/update conda requirements
	conda env export > requirements.yml

.PHONY: convert-m2mat
convert-m2mat: ## convert serpent output files to mat files
	cd scripts && octave-cli convert_m2mat.m || true

# Serpent
.PHONY: push-serpent
push-serpent: ## push serpent inputs
	rsync -avzP ./Serpent $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: push-serpent-dry
push-serpent-dry: ## push serpent inputs dry
	rsync -anv ./Serpent $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: pull-serpent
pull-serpent: ## pull serpent data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/Serpent .

.PHONY: pull-serpent-dry
pull-serpent-dry: ## pull dry serpent data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/Serpent .

# Dragon
.PHONY: push-dragon
push-dragon: ## push all dragon inputs
	rsync -avzP ./Dragon $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: push-dragon-dry
push-dragon-dry: ## push all dragon inputs dry
	rsync -anv ./Dragon $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: pull-dragon
pull-dragon: ## pull all dragon inputs
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/Dragon .

.PHONY: pull-dragon-dry
pull-dragon-dry: ## pull all dragon inputs dry
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/Dragon .

# 1L
.PHONY: push-1L
push-1L: ## push 1L_SHORT inputs
	rsync -avzP ./Dragon/1L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: push-1L-dry
push-1L-dry: ## push 1L_SHORT inputs dry
	rsync -anv ./Dragon/1L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: pull-1L
pull-1L: ## pull 1L_SHORT data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/1L ./Dragon

.PHONY: pull-1L-dry
pull-1L-dry: ## pull dry 1L_SHORT data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/1L ./Dragon

# 2L
.PHONY: push-2L
push-2L: ## push 2L inputs
	rsync -avzP ./Dragon/2L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: push-2L-dry
push-2L-dry: ## push 2L inputs dry
	rsync -anv ./Dragon/2L $(REMOTE_SERV):$(SYNC_DIR) --exclude 'output_*' --delete

.PHONY: pull-2L
pull-2L: ## pull 2L data
	rsync -avzP $(REMOTE_SERV):$(SYNC_DIR)/2L ./Dragon

.PHONY: pull-2L-dry
pull-2L-dry: ## pull dry 1L_LONG data
	rsync -anv $(REMOTE_SERV):$(SYNC_DIR)/2L ./Dragon

.PHONY: keff
keff: ## extract keff data from *.result files using ripgrep
	rg -u -o -I '\|\+.*?(\d+\.\d+e.\d+)\s+Keff=\s+(\d+\.\d+e.\d+).*?$' -r '$1 $2' | cat > keff.txt

.PHONY: convert-eps-to-png
convert-eps-to-png:
	for f in `find . -name "*.eps" -type f`; do \
		convert -density 512 -colorspace sRGB "$$f" -quality 100 -flatten -sharpen 0x1.0 $${f%eps}png; \
		echo "$$f"; \
	done;

.PHONY: convert-pdf-to-png
convert-pdf-to-png:
	for f in `find . -name "*.pdf" -type f`; do \
		convert -density 512 -colorspace sRGB "$$f" -quality 100 -flatten -sharpen 0x1.0 $${f%pdf}png; \
		echo "$$f"; \
	done;

.PHONY: archive
archive: ## create archive for distribution
	rm -f msca.zip
	git archive -o msca.zip HEAD
	zip -ur msca.zip Serpent
	zip -ur msca.zip Dragon -x "*.o2m" -x "*.l2m" -x "**/run" -x "**/_*" -x "*.pid"

.PHONY: clean
clean:  ## clean up project
	find . -type d -name __pycache__ -exec rm -r {} \+
	find . -type d -name .mypy_cache -exec rm -r {} \+
