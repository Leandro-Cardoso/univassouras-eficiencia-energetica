#!/usr/bin/env bash

# COMAND: /usr/bin/time -v ./PROGRAM

RUNS=${1:-5}

PROGRAMS=(
"bad_cpp:./bad_cpp"
"good_cpp:./good_cpp"
"bad_python:python3 bad_python.py"
"good_python:python3 good_python.py"
)

TMP_DIR=$(mktemp -d)

cleanup() {
rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo
echo "==========================================="
echo " Benchmark de Eficiência Computacional"
echo " Execuções por teste: $RUNS"
echo "==========================================="
echo

printf "%-15s %-12s %-12s %-12s\n" \
"Programa" \
"Tempo(s)" \
"CPU(s)" \
"Mem(KB)"

printf "%-15s %-12s %-12s %-12s\n" \
"---------------" \
"------------" \
"------------" \
"------------"

echo "program,time,cpu,memory" > benchmark_time_results.csv

for entry in "${PROGRAMS[@]}"
do
name="${entry%%:*}"
cmd="${entry#*:}"

```
total_time=0
total_cpu=0
total_mem=0

for ((i=1; i<=RUNS; i++))
do
    /usr/bin/time -v bash -c "$cmd" \
        > /dev/null \
        2> "$TMP_DIR/result.txt"

    real_time=$(grep "Elapsed (wall clock) time" "$TMP_DIR/result.txt" | awk '{print $8}')

    cpu_time=$(grep "User time (seconds)" "$TMP_DIR/result.txt" | awk '{print $4}')

    mem=$(grep "Maximum resident set size" "$TMP_DIR/result.txt" | awk '{print $6}')

    IFS=: read -r m s <<< "$real_time"

    if [[ -z "$s" ]]
    then
        seconds="$m"
    else
        seconds=$(awk "BEGIN {print ($m*60)+$s}")
    fi

    total_time=$(awk "BEGIN {print $total_time+$seconds}")
    total_cpu=$(awk "BEGIN {print $total_cpu+$cpu_time}")
    total_mem=$((total_mem+mem))
done

avg_time=$(awk "BEGIN {printf \"%.4f\", $total_time/$RUNS}")
avg_cpu=$(awk "BEGIN {printf \"%.4f\", $total_cpu/$RUNS}")
avg_mem=$((total_mem/RUNS))

printf "%-15s %-12s %-12s %-12s\n" \
    "$name" \
    "$avg_time" \
    "$avg_cpu" \
    "$avg_mem"

echo "$name,$avg_time,$avg_cpu,$avg_mem" >> benchmark_time_results.csv
```
done

echo
echo "CSV salvo em:"
echo "benchmark_time_results.csv"
echo
