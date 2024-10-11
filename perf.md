TODO 火焰图

常用命令

1. 查看网卡流量带宽
`sar -n DEV 2`


NFS抓特定函数调用时延：

func_time_stats.stp

#! /usr/bin/env stap
/*
 * func_time_stats.stp
 * usage: func_time_stats.stp function_probe
 */

global start, intervals

probe $1 { start[tid()] = gettimeofday_us() }
probe $1.return
{
  t = gettimeofday_us() 
  old_t = start[tid()]
  if (old_t) intervals <<< t - old_t
  delete start[tid()]
}
probe end
{
  printf("intervals min:%dus avg:%dus max:%dus count:%d variance:%d\n",
         @min(intervals), @avg(intervals), @max(intervals),
         @count(intervals), @variance(intervals, 3))
  print(@hist_log(intervals));
}

stap -v func_time_stats.stp 'module("nfsd").function("nfsd_write")'

下载kernel-devel-[版本号]、kernel-debuginfo-[版本号]、kernel-debuginfo-common-[版本号]

yum -y install systemtap systemtap-runtime
