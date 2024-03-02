#!/bin/bash

############################################################################
#    监控ganesha进程内存占用，每10秒检测一次，如果内存超过阈值则生成corefile    #
############################################################################

process_name="ganesah.nfsd"

# 设置内存阈值（单位 KB）
memory_threshold=1048576 # 1GB

pid=$(pgrep "$process_name")

if [ -z "$pid" ]; then
    echo "进场 $process_name 不存在"
    exit 1
fi

echo "monitor process: $process_name pid: $pid"

while true; do
  # 获取进程占用内存大小 （单位: KB）
  memory_usage=$(pmap -x $pid | tail -n 1 | awk '{print $3}')

  # 判断内存占用是否超过阈值
  if [ "$memory_usage" -gt "$memory_threshold" ]; then
    echo "进程 $process_name 的内存占用超过 $((memory_threshold / 1024)) GB"

    gcore $pid

    if [ "$?" -eq 0 ];then
      echo "dump core sucess"
    else
      echo "dump core failed"
    fi
  fi

  sleep 10
done