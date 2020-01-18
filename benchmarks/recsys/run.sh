#!/bin/bash

# recsys/run.sh

# --
# Download data

mkdir -p data

wget http://public.sdh.cloud/prog-eval-data/recsys/ml-10m.ratings.dat.gz -O data/ml-10m.ratings.dat.gz

gunzip data/*.gz

# --
# Prep data

python prep.py

# =============== TESTERS: EVERYTHING ABOVE THIS LINE HAS ALREADY BEEN RUN ==============

# --
# Run training

python main.py

# --
# Check correctness

python validate.py

# A correct solution should print something like
# {
#     "status": "PASS", 
#     "p_at_01": 0.5122212999799651, 
#     "p_at_05": 0.40450213228770143, 
#     "p_at_10": 0.33878187698560347
# }
