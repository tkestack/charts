#!/usr/bin/env bash

: ${BACKEND:=openai-chat}
: ${MODEL_NAME:=deepseek-r1}
: ${ENDPOINT:=/v1/chat/completions}
: ${DATASET_NAME:=sharegpt}
: ${DATASET_PATH:=ShareGPT_V3_unfiltered_cleaned_split.json}
: ${NUM_PROMPTS:=1000}
: ${HOST:=127.0.0.1}
: ${PORT:=8000}

echo "Running benchmark for ${BACKEND} with model ${MODEL_NAME} on dataset ${DATASET_NAME} at ${HOST}:${PORT}"

python3 vllm/benchmarks/benchmark_serving.py \
    --backend ${BACKEND} \
    --model ${MODEL_NAME} \
    --endpoint ${ENDPOINT} \
    --dataset-name ${DATASET_NAME} \
    --dataset-path ${DATASET_PATH} \
    --num-prompts ${NUM_PROMPTS} \
    --host ${HOST} \
    --port ${PORT}
