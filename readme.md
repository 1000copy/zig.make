进来目录看到一个窗口系统的批处理看名字猜到是可以生成makeexe的。执行后发现需要vcbuild。意料之中。安装了vc express，在回头执行这个批处理，发现成功生成make的可执行文件。这个构建批处理文件输出比较有价值，它打印出来全部编译文件订单。显然可以不看源代码的情况下就可以获得构建c的文件了。这个有用。一般来说，c的构建就是把所有文件丢进工程即可。看看是不是这个工程也是如此。

接下来zig init-exe，把看到的构建过程输出的记录中所有的c文件，把他们加入到
addCSourceFiles，然后执行zig build根据报错添加宏定义和包含文件目录位置。一个个多处理错误。居然不到一个小时，把它给构建成功了。
不错啊运气挺好的。

构建系统的关键词。在编译make源代码时记录下来的不懂的关键词。
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
- [ ] 6600的changelog。牛