1. 查看目录下哪个子目录占用空间大
`du -s /* | sort -nr`

2. 监控某个文件的变化，被哪个进程修改等。 audit工具的使用
2.1 audit工具介绍
   audit是各内核级的审计工具，允许对Linux操作系统上发生的各种时间进行审计和记录。Linux审计框架提供了强大的功能，允许管理员跟踪系统事件，包括文件访问、用户行为、系统配置变更等，以便于监控系统的安全性和合规性。
2.2 使用方法
   a. 启动audit
   service auditd status/start/restart
   b. 查看监控规则
   auditctl -l
   c. 设置监控规则，比如新增要监控的文件
   auditctl -w <file/directory> -p <previlege> -k <key_name>
   以上<file/directory>为要监控的目标文件或目录，-p为所要监控的权限，可以是rwxa中的任意一个或多个，r可读，w可写，x可执行，a代表文件类型，<key_name>为新增的规则的名字，可以根据名字筛选该条规则的audit日志
   d. 查看监控日志
   ausearch -k <key_name>
   e. 删除所有规则
   auditctl -D
   以上为基础命令，详见https://eternalcenter.com/auditd/
