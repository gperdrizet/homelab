# Arkk backup triage (2026 incident)

Temporary rescue target is 2.7T RAID0 on `pyrite`. Plan is to fill it to the gills and see were we are. Good news is most of the stuff on `arkk` is code repos that are on GitHub.

---

## Summary: what is copied and what is not

**Estimated footprint:** ~1.8T of the 2.7T budget (≈0.9T headroom), after
exclusions and checkpoint thinning.

### Copied (kept)

- **Whole project directories** — see "Direct copy whole directories" below.
- **Project directories minus their bulk data/model dirs** — see "Copy with
  exclusion". The code, configs, and small artifacts are kept; large
  regenerable/redownloadable data is dropped.
- **`rpm` GAN projects** — source, `image_datasets/`, curated `specimens/`, and
  generated art (`gan_output/` / `gan_images/`) are kept whole. Training
  checkpoints are **thinned** to ~35 evenly-spaced per run + the final one.
- **Git history is preserved** (`.git/` is not excluded).

### Not copied (dropped)

- **Regenerable boilerplate** at any depth: `__pycache__`, `*.pyc/*.pyo`,
  `.venv*`, `venv`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`, `.tox`,
  `.ipynb_checkpoints`, `node_modules`, `.vscode`, `.idea`, `.DS_Store`,
  `Thumbs.db`, `*.log`, `*.tmp`.
- **Large redownloadable/regenerable data** carved out per project (examples):
  - `alpaca.ai.v2/data` (914G — the whole dataset), `binance.ai/data` (874G)
  - `matrix-llama_cpp_chatbot/models_fast_scratch` (517G), other `models/` dirs
  - `opensearch` PMC/pubmed/wikipedia corpora, `pubsum` PMC + tarballs (~434G)
  - `llm_detector` model + data dirs, `kaggle` data dirs
- **All periodic training-checkpoint churn** beyond the thinned ladder
  (~3.8T of `rpm` collapses to ~110G).
- **Top-level dirs not on either list are intentionally skipped** (e.g. `steam`,
  `nvidia`, `stable_diffusion`, `redis-stable`, OS/tool caches).

### Transfer method

Source is copied over an **NFS mount on a pair of bonded gigabit Ethernet links
wired directly between the two machines** (arkk exports the read-only array;
pyrite mounts it locally, e.g. at `/mnt/arkk`). rsync therefore runs against a
local path — no ssh transport. See "Run procedure" at the end of this document.

---

## Arkk contents

Approximately 9.6T of 15.0T full:

```
104K    ./2023_jobsearch
15M     ./2024_jobsearch
43M     ./2025_jobsearch
70G     ./4geeks_repos
914G    ./alpaca.ai.v2
36K     ./ask_agatha
8.1M    ./attack
3.7G    ./bartleby
682M    ./bartleby_launch_video
926G    ./binance.ai
249M    ./Binoculars
3.2G    ./bitsandbytes
82M     ./bitsandbytes-0.42.0
1.2G    ./computer_vision
332K    ./crypto
4.0K    ./disk_use.sh
204K    ./DMZ
2.1G    ./DS-ML_course_materials
660M    ./dynamical_systems
35M     ./ensembleset
3.0G    ./ensembleswarm
80M     ./firecast.ai
6.1G    ./fullstack
22M     ./GCSB_MLE
477M    ./Geekbench-6.1.0-Linux
15G     ./hf-agents-course
2.1G    ./hill_climber
0       ./huggingface_model_cache
15G     ./huggingface_transformers_cache
0       ./input_dropout
87G     ./kaggle
849M    ./leaderboard
332K    ./linkedin_regression
4.0G    ./LLaMA3-binoculars_score
101G    ./llm_detector
11G     ./llm_detector_benchmarking
2.2G    ./LMC-enrollment-forecast
du: cannot read directory './logkeep/postgres_data': Permission denied
18M     ./logkeep
520M    ./longer-limbs
34M     ./lost+found
13G     ./matrix-gpt4all_chatbot
517G    ./matrix-llama_cpp_chatbot
36M     ./matrix-llama_cpp_wargames
5.0M    ./matrix-nio
1.6G    ./MCP_hackathon
139M    ./meteorite
1.3G    ./mpss-3.8.6
7.1G    ./nvidia
564G    ./opensearch
24G     ./picam
du: cannot read directory './postgresql/16': Permission denied
16K     ./postgresql
4.1G    ./postit
2.2M    ./pshitt
438G    ./pubsum
4.0K    ./PyPI_recovery_codes.txt
289M    ./redis-stable
476M    ./resumate
13M     ./RhT_monitor
4.9T    ./rpm
30G     ./seedscan
5.4G    ./stable_diffusion
263G    ./steam
4.0K    ./testPyPI_recovery_codes.txt
3.0M    ./tf-benchmarks
12M     ./TTS
182M    ./twitchtalk
37M     ./user_authentication
12K     ./wargames
```

## Copy targets:

### Direct copy whole directories

These should be copied as complete directories (except for our general exclusions like `.venv` directories)

```
2023_jobsearch
2024_jobsearch
2025_jobsearch
ask_agatha
attack
bartleby_launch_video
Binoculars
crypto
disk_use.sh
DMZ
dynamical_systems
ensembleset
firecast.ai
GCSB_MLE
input_dropout
LLaMA3-binoculars_score
LMC-enrollment-forecast
linkedin_regression
longer-limbs
matrix-llama_cpp_wargames
matrix-nio
MCP_hackathon
meteorite
pshitt
resumate
RhT_monitor
PyPI_recovery_codes.txt
testPyPI_recovery_codes.txt
TTS
user_authentication
wargames
DS-ML_course_materials
ensembleswarm
fullstack
hf-agents-course
hill_climber
picam
seedscan
```

### Copy with exclusion

**Copy:**

```
4geeks_repos
alpaca.ai.v2
bartleby
binance.ai
kaggle
llm_detector
matrix-gpt4all_chatbot
matrix-llama_cpp_chatbot
opensearch
postit
pubsum
```

**Exclude**
```
4geeks_repos/archived
alpaca.ai.v2/data/*
alpaca.ai.v2/logs/*
bartleby/bitsandbytes-0.42.0
binance.ai/data/*
binance.ai/logs/*
kaggle/data
kaggle/calorie-expenditure/notebooks/ensembleset_data/*
kaggle/microbusiness-density-forecast/data/*
kaggle/microbusiness-density-forecast/logs/*
llm_detector/api/models--meta-llama--Meta-Llama-3-8B
llm_detector/api/models--meta-llama--Meta-Llama-3-8B-instruct
llm_detector/classifier/data/*
llm_detector/perplexity_ratio_score/data/*
matrix-gpt4all_chatbot/models/*
matrix-llama_cpp_chatbot/models_fast_scratch
matrix-llama_cpp_chatbot/models/*
opensearch/semantic_search/nfs_raid_data/PMC000xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC001xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC002xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC003xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC004xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC005xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC006xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC007xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC008xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC009xxxxxx
opensearch/semantic_search/nfs_raid_data/PMC010xxxxxx
opensearch/semantic_search/nfs_raid_data/pubmed
opensearch/semantic_search/nfs_raid_data/tarballs/*
opensearch/semantic_search/nfs_raid_data/wikipedia/3.1-extraction_summary.json
opensearch/semantic_search/nfs_raid_data/wikipedia/3.2-extracted_text.h5
opensearch/semantic_search/nfs_raid_data/wikipedia/4.1-parse_summary.json
opensearch/semantic_search/nfs_raid_data/wikipedia/4.2-parsed_text.h5
opensearch/semantic_search/nfs_raid_data/wikipedia/5.1-embedding_summary.json
opensearch/semantic_search/nfs_raid_data/wikipedia/5.2-embedded_data.h5
opensearch/semantic_search/nfs_raid_data/wikipedia/6.1-load_summary.json
opensearch/semantic_search/nfs_raid_data/wikipedia/enwiki-20240930-cirrussearch-content.json.gz
opensearch/semantic_search/nfs_raid_data/wikipedia/enwiki-20240930-cirrussearch-content.json.gz.bak
opensearch/semantic_search/nfs_raid_data/wikipedia/enwiki-20240930-cirrussearch-general.json.gz
postit/model/*
pubsum/pubsum/PMC_OA_comm_data/PMC000xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC001xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC002xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC003xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC004xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC005xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC006xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC007xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC008xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC009xxxxxx
pubsum/pubsum/PMC_OA_comm_data/PMC010xxxxxx
pubsum/pubsum/PMC_OA_comm_data/tarballs/*
```

**General exclusions**
```
__pycache__
.venv
.venv-GPU
```

---

## rpm (4.9T → ~1.2T target)

`rpm` is a collection of de-novo GAN training projects. They all share the same
layout: tiny source (`*.py`, `train.sh`, `functions/`), an irreplaceable
`image_datasets/`, generated art in `gan_output/` (a.k.a. `gan_images/`), and a
massive `training_checkpoints/` directory that is periodic-save churn. **~3.8T of
the 4.9T is checkpoint churn.** Strategy: keep code + datasets + generated art,
and thin the checkpoints to a sparse progression ladder.

### Checkpoint thinning policy

Applies to every `training_checkpoints/` directory below.

- Keep an **evenly-spaced ladder of ~35 checkpoints** across the run (enough to
  reconstruct the training trajectory / render a progression video).
- **Always keep the final complete checkpoint** (the usable trained model).
- If a run has ≤ 35 checkpoints already, keep them all.
- Keep both `generator_model_f*` and `discriminator_model_f*` where both exist.
  Note: the `.h5` runs saved **generator only**; the main skylines run saved
  generator + discriminator as SavedModel directories.
- Naming is uniform: `generator_model_f<7-digit-frame>` (either an `.h5` file or
  a SavedModel dir). The helper script computes a per-directory stride so exactly
  ~35 evenly-spaced checkpoints + the final one survive.

### training_checkpoints to THIN

```
3.2T  skylines/skylines/skylines/data/2024-02-17/training_checkpoints   (SavedModel dirs, gen+disc)
185G  NASA_nebulae/NASA_training/training_checkpoints
119G  birds/birds.3/training_checkpoints
104G  skylines/skylines.2/training_checkpoints
100G  birds/birds.4/training_checkpoints
31G   skylines/skylines.1/training_checkpoints
21G   flowers/flowraxx.1/1024x1024.2/training_checkpoints
1.6G  median_meme/32x32_latent_dim_1000/training_checkpoints
929M  median_meme/64x64_latent_dim_100/training_checkpoints
896M  single_image_gan/training_checkpoints
841M  median_meme/128x128_latent_dim_100/training_checkpoints
563M  median_meme/32x32_latent_dim_100/training_checkpoints
174M  median_meme/example_notebooks/training_checkpoints
```

Expected post-thin footprint: ~35 checkpoints per run ≈ **~100–130G total**
(down from ~3.8T).

### Keep whole (irreplaceable — datasets, source, generated art)

- All `image_datasets/`, `specimens/`, `*_dataset/`, `orignal_dataset/`
- All `gan_output/` and `gan_images/` (generated art — the actual product)
  - Large ones to be aware of: `flowers/flowraxx.1/1024x1024.2/gan_images` 178G,
    `skylines/skylines.1/gan_output` 91G, `NASA_nebulae/NASA_training/gan_output`
    89G, `skylines/skylines.2/gan_output` 28G, skylines main `gan_output` 26G.
    If space runs short, these are the next thinning candidates after checkpoints.
- All source: `*.py`, `*.sh`, `*.md`, `functions/`, `README`, `LICENSE`, notes
- `clustered_datasets/*` (assembled feature sets — 141G, keep)
- Training/preview videos: `training-*.mp4`, `NASA_training/*.mp4`, etc.
- Small subprojects whole (minus general exclusions): `fruit`, `hands`, `avopix`,
  `image_getter`, `image_cluster`, `image_scaler`, `degrees_of_freedom`,
  `single_image_gan` (source + output), `welcome_library`, `experimental`

### General exclusions (rpm-wide)

```
__pycache__
.venv
.venv-GPU
*/training_checkpoints  (except the ~35 kept per policy above)
```

Note: `.git` is **not** excluded — git history is preserved. The full
boilerplate exclusion list (editor/IDE, node_modules, Python caches, OS cruft)
lives in `scripts/excludes.txt`.

---

## Run procedure

Helper scripts live in `scripts/` next to this document:

| File | Role |
|------|------|
| `targets.txt` | Top-level paths to copy (relative to source root) |
| `excludes.txt` | Per-project + boilerplate rsync excludes |
| `checkpoint_dirs.txt` | `training_checkpoints` dirs to thin |
| `rsync_selected_from_arkk.sh` | Bulk selective copy (rsync `-R`, applies excludes) |
| `thin_checkpoints_from_arkk.sh` | Copies the thinned checkpoint ladder |
| `run_backup.sh` | Runs both passes in order, with logging + preflight |

### 1. Wire and mount the transport

Connect the bonded direct GbE link, then NFS-mount the read-only arkk array on
pyrite (arkk exports it; pyrite mounts it locally, e.g. `/mnt/arkk`):

```bash
sudo mount -t nfs4 -o ro,hard,noatime,nosuid,nodev,noexec \
  192.168.2.1:/mnt/arkk /mnt/arkk
findmnt /mnt/arkk        # confirm it is mounted and non-empty
```

### 2. Make the rescue target writable (one-time)

```bash
sudo chown "$USER" /mnt/glass
```

### 3. Dry run first (get the real size), inside tmux

```bash
tmux new -s backup
cd ~/homelab/docs/machines/arkk/scripts
./run_backup.sh -s /mnt/arkk -d /mnt/glass/arkk -n   # rsync --stats reports totals
```

### 4. Real run

```bash
./run_backup.sh -s /mnt/arkk -d /mnt/glass/arkk
```

The bulk pass runs **parallel rsync streams** (default 4, `-j N` to change) — one
per top-level target — which avoids the single-TCP-stream ceiling on the bonded
link. `rpm` is split into its 17 subdirectories in `targets.txt` so it
parallelizes too. Tune with e.g. `-j 6` if the link/disks have headroom.

Re-run the same command to catch partials (rsync skips already-complete files).
Logs are written to `/mnt/glass/arkk/_backup_logs/`.

### 5. Verify, then rebuild parity

Spot-check the irreplaceable `rpm` datasets (sizes/counts). Only **after** the
backup is verified, re-add the spare and rebuild the degraded array — see
[RAID_RECOVERY_2026.md](RAID_RECOVERY_2026.md). Keep the array read-only until
the backup is done.
