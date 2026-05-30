#!/usr/bin/env bash

# COMAND: perf stat ./PROGRAM

RUNS=${1:-5}

PROGRAMS=(
    "bad_cpp:./bad_cpp"
    "good_cpp:./good_cpp"
    "bad_python:python3 bad_python.py"
    "good_python:python3 good_python.py"
)

TMP_DIR=$(mktemp -d)

trap "rm -rf $TMP_DIR" EXIT

echo "program,time,cpu,memory,cycles,instructions,ipc" > benchmark_perf_results.csv

printf "\n"
printf "%-15s %-10s %-10s %-15s %-15s %-15s %-10s\n" \
"Program" \
"Time(s)" \
"CPU(s)" \
"Memory(KB)" \
"Cycles" \
"Instructions" \
"IPC"
printf "\n"

for entry in "${PROGRAMS[@]}"
do
    name="${entry%%:*}"
    cmd="${entry#*:}"

    total_time=0
    total_cpu=0
    total_mem=0
    total_cycles=0
    total_instr=0

    for ((i=1; i<=RUNS; i++))
    do

        /usr/bin/time -v bash -c "$cmd" \
            > /dev/null \
            2> "$TMP_DIR/time.txt"

        cpu=$(grep "User time (seconds)" "$TMP_DIR/time.txt" | awk '{print $4}')
        mem=$(grep "Maximum resident set size" "$TMP_DIR/time.txt" | awk '{print $6}')

        elapsed=$(grep "Elapsed (wall clock) time" "$TMP_DIR/time.txt" | awk '{print $8}')

        IFS=: read -r m s <<< "$elapsed"

        if [[ -z "$s" ]]; then
            seconds="$m"
        else
            seconds=$(awk "BEGIN {print ($m*60)+$s}")
        fi

        perf stat -e cycles,instructions \
            bash -c "$cmd" \
            > /dev/null \
            2> "$TMP_DIR/perf.txt"

        cycles=$(grep "cycles" "$TMP_DIR/perf.txt" | head -1 | awk '{print $1}' | tr -d '.,')
        instr=$(grep "instructions" "$TMP_DIR/perf.txt" | head -1 | awk '{print $1}' | tr -d '.,')

        total_time=$(awk "BEGIN{print $total_time+$seconds}")
        total_cpu=$(awk "BEGIN{print $total_cpu+$cpu}")
        total_mem=$((total_mem+mem))
        total_cycles=$(awk "BEGIN{print $total_cycles+$cycles}")
        total_instr=$(awk "BEGIN{print $total_instr+$instr}")
    done

    avg_time=$(awk "BEGIN{printf \"%.4f\", $total_time/$RUNS}")
    avg_cpu=$(awk "BEGIN{printf \"%.4f\", $total_cpu/$RUNS}")
    avg_mem=$((total_mem/RUNS))

    avg_cycles=$(awk "BEGIN{printf \"%.0f\", $total_cycles/$RUNS}")
    avg_instr=$(awk "BEGIN{printf \"%.0f\", $total_instr/$RUNS}")

    ipc=$(awk "BEGIN{
        if($avg_cycles==0)
            print 0;
        else
            printf \"%.3f\", $avg_instr/$avg_cycles
    }")

    printf "%-15s %-10s %-10s %-15s %-15s %-15s %-10s\n" \
        "$name" \
        "$avg_time" \
        "$avg_cpu" \
        "$avg_mem" \
        "$avg_cycles" \
        "$avg_instr" \
        "$ipc"

    echo "$name,$avg_time,$avg_cpu,$avg_mem,$avg_cycles,$avg_instr,$ipc" \
        >> benchmark_perf_results.csv

done

printf "\n"
printf "Arquivo gerado: benchmark_perf_results.csv"
printf "\n\n"
