# Arkk backup triage (2026 incident)

Temporary rescue target is 2.7T RAID0 on `pyrite`. Plan is to fill it to the gills and see were we are. Good news is most of the stuff on `arkk` is code repos that are on GitHub.

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

```
564G    ./opensearch
4.1G    ./postit
438G    ./pubsum
4.9T    ./rpm
```

### Direct copy whole directories

**Small**

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
```

**Large**

```
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
```

**General exclusions**
```
__pycache__
.venv
.venv-GPU
```
