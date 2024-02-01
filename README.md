## 如何转换Makefile到Zig build？

HZLUG会上，有人提到，既然Zig的一个重要应用就是作为C语言的工具链，做C语言的构建工具以便替代make，那么是否有工具把Makefile自动转换为Zig的build.zig呢？

下来思考下，觉得很有兴趣做一个工具，把Makefile转换为build.zig。

我也先查询了下，确实有人想要做这个事情，但是代码看起来还刚刚开始并且从一年没有更新了。[zig-foundation](https://github.com/masoncowen/zig-foundation)
我想要这个事情，应该有几个细节分解：

1. 解析Makefile。这个最好的方法，就是找到现在的Make工具，比如GNU Make。拿到源代码，编译通过，找到内部的数据结构
2. 转换Make的内部结构，生成对应的build.zig文件。

显然第一步是最麻烦的，我的想法是第一步继续细分，首先使用zig来构建make的源代码。

这个repo就是此项任务的承载代码仓库。

目前，应该在Windows和OS X上使用Zig编译通过[Gnu Make 4.4.1源代码](https://ftp.gnu.org/gnu/make/?C=M;O=D)。

基本过程就是；

1. 找到需要加入构建工程的源代码文件。
2. 需要现场生成的文件
3. 源代码编译需要的宏定义
4. 指定需要的包含目录位置

源代码目录内的文件非常多，且不同的操作系统应该是文件并不相同。

进来目录看到一个窗口系统的批处理看名字猜到是可以生成makeexe的。执行后发现需要vcbuild。意料之中。安装了vc express，在回头执行这个批处理，发现成功生成make的可执行文件。这个构建批处理文件输出比较有价值，它打印出来全部编译文件订单。显然可以不看源代码的情况下就可以获得构建c的文件了。这个有用。一般来说，c的构建就是把所有文件丢进工程即可。看看是不是这个工程也是如此。

但是我在目录中发现有一个build.sh文件，显然是为了在没有Make工具的系统中用来构建的，执行此文件（/bin/bash build.sh),发现它确实在MAC上成功构建了make可执行文件。相应的build_w32.bat是在Windows上构建的批处理脚本，在Windows上执行此批处理，发现它确实在上成功构建了make可执行文件。

并且它们两个都会输出一个被编译的文件列表。我提取此列表，接下来zig init-exe，把看到的构建过程输出的记录中所有的c文件，把他们丢到build.zig文件中的语句`exe.addCSourceFiles();`的参数内。然后执行zig build根据报错添加宏定义和包含文件目录位置。一个个多处理错误。居然不到一个小时，把它给构建成功了。

不错啊运气挺好的。这样第一步就完成了。

编译会提示没有config.h文件，这个在Windows上有一个对应的config.h.W32文件，把它拷贝到config.h上即可。对应在mac上，需要（/bin/bash build.sh)去生成。

至于3，4步，则是在编译源代码的过程中，根据错误提示一个个的加上去的，这个步骤需要解决一个在解决下一个，无法一步估计的出来，因此做的时间比较久，也比较考验人的耐心。宏定义在批处理文件和shell文件内一定是有多，如果不确定需要定义什么，可以通过查找文本去对应的文件内去找宏定义。很多可以在其中找到。

话休絮烦。总之，一番hack后，可以在mac和windows上通过zig build编译make了。虽然需要一些条件，看起来在mac上需要先用build.sh执行一遍，生成一些类似config.h的配置文件。

即便如此，这样做依然有意义，因为一旦我可以使用zig build构建make工程，就可以使用zig的test工具链来测试make的源代码了。于是可以迭代式的替代C了。就像[Iterative Replacement of C with Zig](https://tiehu.is/blog/zig1)描述的一样。

做的过程中，我确实还有新的发现。

另外一条技术路径， 如果我是仅仅需要编译make的话，我大可不必使用zig，而只是用make工具链即可。一样可以遍历源代码找到转换Makefile到zig build的方式。
第三条技术路径，就是寻找现成的Makefile parser，还真有，但是不知道是否齐全。比如js写的[makefile-parser](https://github.com/kba/makefile-parser),py写的[pymake](https://github.com/linuxlizard/pymake)。
还有就是，试图使用zig编译make的过程中，我发现大概是c语言工程的通病，稍大一点就需要借助大量的其他工具，其中用了一堆古老的东西gnu m4,guile,automake,autoconf，pkg-config等等。还使用perl做测试。实在是有必要使用zig这样的allinone来刷新下它的工具链条了。

一个不好的感觉也在这个过程中逐步形成：就是zig build和makefile做这个构建的方法并不完全一致，因此可以认为是并不同构的，未必可以自动的转换过来。

构建系统的关键词。在编译make源代码时记录下来的不懂的关键词。
- [ ] what is Make:Make : It was created by Stuart Feldman in April 1976 at Bell Labs, received the 2003 ACM Software System Award for authoring the tool.
- [ ] pkgconfig。开发人员可以方便地获取库的各种必要信息，比如包含文件的位置和lib的位置。gcc main.c `pkg-config --cflags --libs gtk+-2.0` -o main
- [ ] make make之前为什么需要make configure
- [ ] make的源代码中的m4
- [ ] m4代码的语法在哪里可以找到
- [ ] c语言自己有宏，没什么还需要m4呢
- [ ] 扩展名为m4的文件是什么
- [ ] M4和Make之间的关系是什么
- [ ] 扩展名ac是什么？举例gnu autoconf 
- [ ] automake 扩展名为am，这是什么？
- [ ] automake如何简化make文件的创建的？举例代码
- [ ] 6600的changelog。

接下来就是看代码了。这个debug info打印比较有用：

    ./zig-out/bin/zmake  --debug=VERBOSE -f  simplemake.mk 
    解析代码主要在read.c

有用的资源：
    https://makefiletutorial.com/