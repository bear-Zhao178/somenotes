# 开始gdb调试
gdb调试建立在编译时加了-g参数，具有调试信息的前提
1. 开始调试
`gdb <可执行文件名>`
2. 设置运行参数
`set args <参数列表>`
`<参数列表>`是以空格分隔的所有可执行程序的参数列表，例如：`gdb my_demo.exe arg1 arg2 arg3`
3. 按需设置断点，详见后文断点
4. 运行程序
`run`  可缩写为`r`
`continue`  可缩写为`c`
5. 触发断点或`ctrl+C`使得程序暂停时，可以使用`print`或缩写为`p`打印所需变量值，或其他命令查看所需信息。详见后文打印相关。
6. 调试结束，退出gdb
`quit`  可缩写为`q`

# gdb调试基本命令
1. 单步执行，按行执行，遇到函数调用，作为一行执行，不进入函数调用内部
`next`  可简写为 `n`
2. 单步执行，与`next`区别为遇到函数调用，会进入函数内部，并继续执行
`step`  可简写为 `s`
`finish`  执行完当前函数并返回到上一层函数调用处
3. 打印当前堆栈
`backtrace`  可简写为`bt`
4. 切换为某一层栈
`frame [栈序号]`  可缩写为`f [栈序号]`
用于切到某一层栈，查看对应栈相关信息
5. 打印进程空间中所有线程信息
`info threads`
6. 打印进程空间中所有线程堆栈
`thread apply all bt`  可简写为`thr app all bt`
7. 将gdb调试过程输出重定向到指定文件
`set logging file output_gdb.log`   \# 设置gdb输出重定向到当前目录`output_gdb.log`中，即设置gdb输出文件的路径
`set logging on`    # 这条命令后的gdb所有输出都将输出到指定的文件中
`set logging off`   # 暂停将gdb的输出重定向
8. 打断点
8.1 普通断点
`break`  可简写为`b`，断点可以打到具体某个文件的某一行（如果有多个相同文件，可以指定相对路径），也可以打到某个具体的函数
例如：
`b main`
`b main.c:301`
`b src/handle.c:110`
8.2 观测断点
`watch`  一般不简写，用于观测某个变量变化。被`watch`的变量发生改变时，会打印`old value`和`new value`
使用场景：观测进程中某个全局变量的变化，`watch global_var`，当变量`global_var`发生变化时，gdb会暂停当前程序，并打印`old value`和`new value`，并可通过使用`bt`命令，查看当前是什么逻辑使该变量发生了改变
8.3 条件断点
`break <函数名/文件名:行号> if var == xx`
例如：
`(gdb) b svc_release_it if xprt->xp_type == 4`
典型的使用场景：观察某个结构的引用计数管理逻辑，可以使用条件断点，可以很方便快捷的抓到某个结构完整的引用计数管理逻辑及生命周期。
9. 设置变量值
`set variable var = [值]`  可以直接在`gdb`中手动设置某个变量的值

# gdb调试现有进程
`gdb -p [pid]`  或者 `gdb attach [pid]`

# gdb多线程调试
1. 查看所有线程信息
`info threads`
2. 切换具体线程
`thread [线程序号]`
这里的线程序号指的是gdb中给各线程标的序号，并非线程id
3. 查看某个线程号对应的线程序号
`t f [tid]`
使用场景：定位死锁问题，常常需要打印锁信息，并根据锁信息中记录的持有锁的线程id，切到具体线程，进一步分析，可以使用`t f [tid]`命令，其中tid一般是持有锁的线程id，可以方便快捷的得到持有锁的线程序号，从而使用`t [线程序号]`切换线程
4. 多线程程序禁用自动切换线程
`set scheduler-locking on`
该命令可以锁定为当前线程，其他线程保持暂停状态，并禁用线程自动切换，对应关闭的命令为
`set scheduler-locking off`
禁用线程自动切换期间，可以使用`t [线程序号]`命令手动切线程，线程切换后，自动锁定为切换后的线程，切换前的线程暂停在切换线程那一时刻。

# gdb打印相关
1. 基础打印
`print [变量名]`  可缩写为`p [变量名]`
2. 打印当前栈所有局部变量
`info locals`
3. 打印当前寄存器信息
`info registers`
4. 打印某个地址的内存内容
`x/[len]a [addr]`  `a`是打印格式
`x/[N]c [addr]`  从`addr`处打印`N`个字符
`x/1s [addr]`  从`addr`出打印一个字符串，以`\0`为结尾

# 反汇编
按照反汇编语句进行调试，可以清楚的了解某行代码执行的完整过程，尤其是知道改行代码是否为原子操作
1. 查看当前反汇编代码
`disassemble`
2. 打印下一条将要执行的汇编代码
`set disassemble-next-line on`
3. 按照汇编代码单步执行
`ni`和`si`， 区别相当于`next`和`step`

# gdb分析corefile
通过gdb对corefile进行分析，能够了解进程崩溃产生corefile的原因
1. gdb对corefile进行调试分析
`gdb <可执行文件> <corefile>`
不明确`corefile`是哪个可执行文件产生的，可以使用`file <corefile>`查看`corefile`是哪个文件产生的
2. 主动生成corefile
`gcore -o [corefile前缀] [pid]`
执行以上命令后，将生成带有`corefile前缀`的对应`pid`的`corefile`，可以通过`gdb`对产生的`corefile`进行分析，一般分析进程死锁问题可用本方法。
`gcore`过程中会阻塞进程

# gdb高阶用法
1. 分析进程空间中堆内存gdb脚本，可用于分析coredump文件
```
define my_malloc_stats
  set $in_use = mp_.mmapped_mem
  set $system = mp_.mmapped_mem
  set $arena = &main_arena

  set $arena_n = 0

  # mALLINFo
  while $arena
    set $system = $system + $arena->system_mem

    set $avail = (($arena->top)->size & ~(0x1 | 0x2 | 0x4))

    set $fastavail = 0
    set $i = 0

    # traverse fastbins
    while $i < 10
      set $p = (($arena)->fastbinsY[$i])
      while $p
        set $fastavail = $fastavail + (($p)->size & ~(0x1 | 0x2 | 0x4))
        set $p = $p->fd
      end
      set $i = $i + 1
    end

    set $avail = $avail + $fastavail

    # traverse regular bins
    set $i = 1
    while $i < 128
      set $b = (mbinptr) (((char *) &(($arena)->bins[(($i) - 1) * 2])) - 16)
      set $p = $b->bk
      while $p != $b
        set $avail = $avail + (($p)->size & ~(0x1 | 0x2 | 0x4))
        set $p = $p->bk
      end
      set $i = $i + 1
    end

    printf "Arena: %u\nsystem bytes     = %10lu\nin use bytes     = %10lu\n", $arena_n, $arena->system_mem, ($arena->system_mem - $avail)

    set $in_use = $in_use + ($arena->system_mem - $avail)

    set $arena = $arena->next
    if $arena == &main_arena
      loop_break
    end
    set $arena_n = $arena_n + 1
  end

  printf "Total:\nsystem bytes     = %10lu\nin use bytes     = %10lu\n", $system, $in_use
end
```

2. 用户态core遍历malloc_chunk
```gdb
[root@c75n81p64 lmm]# cat pChunk.gdb
set $total=0
set $alloc=0
set $free=0
set $seq=0
set $chk=(struct malloc_chunk *)(mp_->sbrk_base)
while ($chk != 0)
    set $sz=$chk->size & (~(0x7))
    if ($chk == main_arena->top)
        set $free=$free+$sz
        set $seq=$seq+$sz
        printf "%p, %ld, %d, %ld, %ld, %ld, %ld\n", $chk, $sz, 0, $alloc, $seq, $free, $total
        loop_break
    end
    set $nxt_chk=(struct malloc_chunk *)((char *)$chk + $sz)
    set $used=$nxt_chk->size & 0x1
    if ($used)
        set $alloc=$alloc+$sz
        set $seq=0
    else
        set $free=$free+$sz
        set $seq=$seq+$sz
    end
    printf "%p, %ld, %d, %ld, %ld, %ld, %ld\n", $chk, $sz, $used, $alloc, $seq, $free, $total
    set $chk=$nxt_chk
end
```

3. 通过函数名查到函数地址
`info address [func]`
4. 通过函数地址查到函数名
`info symbol [addr]`

# gdb中使用python脚本
1. 打印相关信息并continue的python脚本
`cat p_bt_c.py`
```python
import gdb

def LogAndC():
    # c_bp为当前栈行号，thread为当前线程id，func为当前栈顶函数名
    c_bp = gdb.selected_frame().find_sal().line
    thread = gdb.selected_thread().ptid[1]
    func = gdb.selected_frame().function().name

    # 判断当前行号是否为554或577
    if c_bp == 554 or c_bp == 577:
        xprt_ref_v = gdb.parse_and_eval('xprt->xp_refcnt')
        print("func {} xprt->xp_refcnt: {} tid {}".format(func, int(xprt_ref_v), int(thread)))
    if c_bp == 1276:
        print("func {} tid {}".format(func, int(thread)))
        gdb.execute("p stat")

    # 执行bt命令，打印堆栈
    gdb.execute("bt")
    # 执行continue
    gdb.execute("c")

class p_bt_c(gdb.Command):
    def __init__(self):
        super(p_bt_c, self).__init__("p_bt_c_func", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        LogAndC()

p_bt_c()
```

2. 执行python脚本
`source p_bt_c.py`  通过`source`命令加载脚本
`p_bt_c`  加载后，可直接使用`p_bt_c`命令

3. gdb脚本的例子
```gdb
[root@node131 lmm]# cat nsm_break.gdb
set $p = ((struct cx_data *) nsm_clnt)->cx_rec
set logging off
set logging file 0109_outfile_ccc_svc_0
set logging on
p nsm_clnt
b svc_ref_it if xprt == $p
b svc_release_it if xprt == $p
b insert_nlm_xprtlist
```

# 根据可执行文件，导出结构体大小
使用`readelf -wi <二进制文件>`命令，可以导出二进制文件中所有结构体大小，形式如下：
```
    <68de>   DW_AT_name        : (indirect string, offset: 0x4915): fsal_xattrent
    <68e2>   DW_AT_byte_size   : 272
    <68e4>   DW_AT_decl_file   : 3
    <68e5>   DW_AT_decl_line   : 535
    <68e7>   DW_AT_sibling     : <0x6913>


    <77ef>   DW_AT_name        : (indirect string, offset: 0x5c71): fsal_export
    <77f3>   DW_AT_byte_size   : 320
    <77f5>   DW_AT_decl_file   : 47
    <77f6>   DW_AT_decl_line   : 2846
    <77f8>   DW_AT_sibling     : <0x785b>


	<7cd2>   DW_AT_name        : (indirect string, offset: 0x4733): export_ops
    <7cd6>   DW_AT_byte_size   : 264
    <7cd8>   DW_AT_decl_file   : 47
    <7cd9>   DW_AT_decl_line   : 676
    <7cdb>   DW_AT_sibling     : <0x7e8e>


    <16a07>   DW_AT_name        : (indirect string, offset: 0x87c5): dirent
    <16a0b>   DW_AT_byte_size   : 280
    <16a0d>   DW_AT_decl_file   : 25
    <16a0e>   DW_AT_decl_line   : 22
    <16a0f>   DW_AT_sibling     : <0x16a50>
	

    <20a3d>   DW_AT_name        : (indirect string, offset: 0x88a9): ceph_state_fd
    <20a41>   DW_AT_byte_size   : 304
    <20a43>   DW_AT_decl_file   : 9
    <20a44>   DW_AT_decl_line   : 96
    <20a45>   DW_AT_sibling     : <0x20a62>
```
其中`byte_size`为结构体大小，`byte_size`上面的是结构体名称