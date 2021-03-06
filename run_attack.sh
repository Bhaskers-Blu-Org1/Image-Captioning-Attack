#!/bin/bash
## Copyright (C) 2017, Hongge Chen <chenhg@mit.edu>
## Copyright (C) 2017, Huan Zhang <ecezhang@ucdavis.edu>
# Use this bash code to run multiple attacks using MSCOCO dataset.
# ATTENTION! you need to specify your own CAPTION_FILE and IMAGE_DIRECTORY before running this bash code!
if [ "$#" -le 2 ]; then
    echo "Usage:" $0 "<offset> <number_attacks> <output_directory> [option 1] [option 2] ..."
    echo "Example:" $0 "0 100 debug_dir --use_keywords --input_feed=\"dog cat\""
    exit 1
fi

OFFSET=$1
NUM_ATTACKS=$2
OUTPUT_DIR=$3

shift
shift
shift

PARAMS=()

for PARAM in "$@"
do
    PARAMS+=("${PARAM}")
done

echo Additional parameters: ${PARAMS[@]}

mkdir -p ${OUTPUT_DIR}

VOCAB_FILE="im2txt/pretrained/word_counts.txt"
CHECKPOINT_PATH="im2txt/pretrained/model2.ckpt-2000000"
# ATTENTION! you need to specify your own CAPTION_FILE and IMAGE_DIRECTORY here!
############################################################################
CAPTION_FILE="/home/hongge/im2txt/EasyCocoEval/coco-caption/annotations/captions_val2014.json"
IMAGE_DIRECTORY="/data2/mscoco/image/val2014/"
############################################################################
bazel build -c opt im2txt/run_attack_BATCH_search_C
set -x
bazel-bin/im2txt/run_attack_BATCH_search_C --checkpoint_path=${CHECKPOINT_PATH}  --caption_file=${CAPTION_FILE} --vocab_file=${VOCAB_FILE}   --input_files=${IMAGE_FILE} --image_directory=${IMAGE_DIRECTORY} --use_logits=True --exp_num=${NUM_ATTACKS} --offset=${OFFSET} --result_directory="${OUTPUT_DIR}" --norm="l2" -seed=8 --C=1 "${PARAMS[@]}" 2>&1|tee ${OUTPUT_DIR}/log_$OFFSET.txt
set +x
rm -r bazel-*


