[toc]



#### 项目组件

1. 自己实现一个通知中心？ 数据如何管理？

   > 认真研读、你可以在这里找到答案轻松过面:https://juejin.im/post/5e5fc16df265da575155723b
   >
   > \1. 实现原理(结构设计、通知如何存储的、name&observer&SEL之间的关系等)
   >  \2. 通知的发送时同步的，还是异步的
   >  \3. NSNotificationCenter接受消息和发送消息是在一个线程里吗?如何异步发送消息
   >
   > \4. NSNotificationQueue是异步还是同步发送?在哪个线程响应
   >  \5. NSNotificationQueue和runloop的关系
   >  \6. 如何保证通知接收的线程在主线程
   >  \7. ⻚面销毁时不移除通知会崩溃吗
   >  \8. 多次添加同一个通知会是什么结果?多次移除通知呢
   >  \9. 下面的方式能接收到通知吗?为什么

2. 设计下载管理器

   > 参考：AFImageDownloader
   >
   > 线程池+阻塞队列
   > 线程池设置最大容量
   > 生产者创建任务，交给线程池，线程池创建线程执行任务，当任务数量大于线程池容量时，把任务放到阻塞队列中等待
   > 任务执行完成后，释放出的线程从阻塞队列中取出任务执行

3. AFN如何保证请求和响应一一对应

   > URLSession，每创建一个task，task都会有一个identifier，通过identier和delegate保存字典中
   >
   > URLSession代理回来，请求数据完成，通过字典的identifier找到delegate，delegate回调数据

4. SDWebImage如何保证高效的展示图片

   > 缓存的设计：内存缓存、磁盘缓存
   >
   > 图片编解码：

5. 多个pod库管理公用的图片

6. 组件化通讯的方式？不同方案的优劣说一下

   > SZYModule

7. 不同进程如何实现共享内存的方式交换数据

8. 地址是如何分页的，按照什么顺序加载

9. 静态库频繁更新版本，导致git仓库比较大，怎么解决

   > [git仓库瘦身](https://www.cnblogs.com/freephp/p/6273082.html)

10. sdimage框架的缓存机制，锁机制，设计方式，编码压缩选择的设计模式，图片下载的设计模式并有无优化建议；其中的锁机制，不仅仅是iOS的互斥锁（自旋）机制，还有iOS的分拆锁和分离锁的大致实现和关系



#### 内存管理

1. oc类占用空间有多大

   > NSObject占用16个字节，内存对齐原则，每次都增加16个字节
   >
   > NSObject对象使用8个字节，int 4个字节，long long 8个字节

2. OC内存管理

   > https://blog.csdn.net/u014600626/article/details/105203131
   >
   > objc_retain(obj)

3. autoreleasepool的实现原理，要知道90%的实现代码

   > Autoreleasepage对象

4. OC对象释放的时候都做了什么？（关联对象、weak、C++析构函数）kvo



#### UI

1. 结合masonary源码解释一下约束是如何设置到view上的，（autolayout如何实现约束的）

2. CoreImage是怎么工作的

3. 如何实现五角星的绘制，多讲述几种实现方案，如何让五角星内响应事件，五角星外不响应事件

4. 如何实现复杂图形，图形中间空洞会传递事件到下一层，图片内容会响应点击事件

   > hitest、poinside，以及手势的控制，事件

5. iOS实现动画的几种方式

6. 离屏渲染的原理，为什么iOS12之后就很少出现了，猜测apple做出如何优化



#### 多线程

1. 多线程AB两个任务异步完成，再做任务c，有哪些实现方式

   > NSOperation
   >
   > GCD Group
   >
   > 条件锁
   >
   > 多个信号量

2. dispatch_semaphore_t有哪些内容

   > struct dispatch_semaphore_s {
   >  DISPATCH_STRUCT_HEADER(dispatch_semaphore_s, dispatch_semaphore_vtable_s);
   >  long dsema_value;   // 当前信号值，当这个值小于0时无法访问加锁资源
   >  long dsema_orig;    // 初始化信号值，限制了同时访问资源的线程数量
   >
   >  size_t dsema_sent_ksignals; //由于mach信号可能会被意外唤醒，通过原子操作来避免虚假信号
   >
   >  semaphore_t dsema_port;
   >  semaphore_t dsema_waiter_port;
   >  size_t dsema_group_waiters;
   >  struct dispatch_sema_notify_s *dsema_notify_head;
   >  struct dispatch_sema_notify_s *dsema_notify_tail;
   > };

3. 
4. 程序启动是在什么时机做的主线程创建？点击图标，load调用，main函数执行？



#### 文件

1. Mach-O文件结构

   > header、loadcommands、data数据区

2. 动态库和静态库的区别

   > https://blog.csdn.net/heipingguowenkong/article/details/90522049

3. 二进制重拍的原理

4. 断点调试的高级技巧：如何确定控制台日志输出的位置？

   > watchpoint: 这个主要是用于观察变量值的具体变化
   >
   > breakpoint: 给某个文件的某一行下断点, (lldb) breakpoint set *--file Foo.m --line 26*
   >
   > image list:
   >
   > https://blog.csdn.net/zhouzhoujianquan/article/details/54949464



#### 设计原则

1. 单一原则

   > GUIBase：信息流
   >
   > 网络库
   >
   > 埋点库

2. 接口隔离原则

   > tableView，设计组件的时候，协议和数据传递；项目中设计

3. 开闭原则

   > 引入第三方使用的时候，都要遵循开闭原则：广告模块、sdwebImage、MJRefresh、网络库

4. 里氏替换原则

   > GUIBase：FeedLoadController -> NetworkController -> SZYViewController -> UIViewController
   >
   > SZYModule：子类继承协议

5. 依赖反转原则



#### 设计模式

1. 生产者消费者模式

   > 直播间IM和展示列表，生产者 ——> 缓冲区 ——> 消费者，缓冲区使用数据结构存储，分析数组和链表存储的差别
   >
   > https://www.cnblogs.com/ZachRobin/p/7451649.html

2. 观察者模式：KVO

3. 框架：MVC、MVVM、MVP



#### 算法题

1. 有100只一模一样的瓶子，编号1-100。其中99瓶是水，一瓶是看起来像水的毒药。只要老鼠喝下一小口毒药，一天后则死亡。现在，你有7只老鼠和一天的时间，如何检验出哪个号码瓶子里是毒药？ 

   > 七只老鼠，每只老鼠的生和死是两个状态，那么可以组成二进制数，ABCDEFG。比如第一瓶，只给G老鼠喝；第十瓶，给D、F喝；以此类推，7只老鼠最多可以检验127瓶水。

2. 无序数组中的中位数，数组长度n

   > 排序、取值

3. 字符串相加得到新的字符串

4. 给定一个非空整数数组，取值范围[0,100]，除了某个元素出现奇数次以外，其余每个元素均出现次数为偶数。找出那个出现次数为奇数次的元素。如果取值范围为[0,100000000]

5. 三个瓶子，每个瓶子装满了一种颜色。每两个瓶子混合，可以均分颜色。现在要三个瓶子最后颜色一样，请问如何平均分配？ 

6. n个无序数里边找最大100个，但是深究  复杂度  lg(100) X n， 这个算法的时间复杂度

7. 4个砝码，整数的，能组合出多少种称量重量

8. 函数f(x)随机生成[0-5]，概率一样，实现g(x)=[0-13]概率一样

9.  算法是一个求组里面有正，负，0，找两个数，他们的和等于给定的目标值

10. 算法题就是0-5的随机数，求0-13，

11. 排序稳定性的定义，常见排序的时间复杂度以及怎么算。

12. 归并排序的递归实现思路，是否可以改成迭代，思路是怎样。

13. 给定正整数n，求最少可以由几个完全平方数来组成，比如12可以是[9,1,1,1]，可以是[4,4,4]。

14. 合并两个有序数组

15. 典型的动态规划题，网上搜就有

16. 何选出买的最多的100条数据。面试官让用最大堆排序



#### 算法

1. 哈希算法

   > cache_t、sideTable、关联对象、runloop

2. 非对称加密算法

   > https认证

3. 对称加密算法

   > https数据传输

4. base64算法

   > 1、可逆性。
   >
   > 2、可以将图片等二进制文件转换为文本文件。
   >
   > 3、可以把非ASCII字符的数据转换成ASCII字符，避免不可见字符。

5. md5算法

   > 1、不可逆性。
   >
   > 2、任意长度的明文字符串，加密后得到的密文字符串是长度固定的，常用来做文件校验



#### 数据结构

1. 哈希表原理，实现一个哈希表

   > http://www.cocoachina.com/cms/wap.php?action=article&id=26391

2. NSObject：isa_t、cache_t、class_rw_t、class_ro_t

3. Category_t

4. Runloop

5. SideTable

6. Block

7. 考察OC对象模型和运行时类方法和实例方法调用细节，以及有分类的情况和闭环的情况。

8. 链表、二叉树（找最近父节点和删除节点）

9. 动态数组分配方式：NSMutableArray的实现原理



#### 语法特性：

1. Block区分，__block的使用，循环引用

   > 能够修改auto成员变量

2. category是如何实现

   > 分类的数据结构
   >
   > 分类加载过程
   >
   > 函数调用
   >
   > +load +initialize
   >
   > 属性（只声明 setter、getter，未实现）

3. kvo的实现原理

   > 派生类，实例对象的isa指向了派生类，派生类的isa指向了class
   >
   > 派生类重写set方法，willChangeValueForKey、didChangeValueForKey方法
   >
   > 手动管理

4. method swizling有那些坑

5. 可以用方法交换代替子类实现kvo吗

   > KVO是对一个具体的实例对象起作用，方法交换是对一个类对象起作用，所有实例对象都会受影响

6. sel是什么

   > 方法选择器，同一个函数名的方法选择器都是同一个

7. 可以用kvo代替notification吗，反过来可以用notification代替kvo吗

   > 影响范围，一个是单个实例对象受影响；全局系统的手法消息受影响

8. 怎么让通知的监听方法在主线程调用



#### Runtime

1. 32位和64位不同？ runtime有什么不一样？

   > tagged pointer
   >
   > non-pointer isa

2. OC方法查找过程，哈希查找、二分查找、线性查找

   > cache_t 哈希查找
   >
   > rw_t，排序后二分查找，未排序线性查找

3. 记录ojc_msgsend执行时间，如何做

   > https://www.jianshu.com/p/641ccf10d1ac

4. 消息转发为什么是三级转发，直接一层转发不可以吗

   > 单一原则：第一层动态解析找方法，找不到以后再转发，第三层拿到方法签名获得invocation

5. 消息转发后最是如何调用函数的

6. 问类加载和类实例化方法，分别在主类分类继承情况下是如何，分类方法覆盖顺序问题。

   



#### 内存管理

1. taggedpointer

   > ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK，指针地址的第一位判断



#### 多线程

1. 子线程的autoreleasepool是何时创建、释放

   > 子线程创建的时候，创建Autoreleasepool，在子线程销毁的时候释放

   

#### 网络

1. 网络优化做的那些

   > 无网络不发网络请求
   >
   > DNS防劫持
   >
   > 数据安全：https，公钥和私钥
   >
   > 减少压缩网络数据，protobuf
   >
   > session复用
   * [网络优化](https://www.jianshu.com/p/e5727c8d8149)

2. 如何应对DNS劫持

   > httpDNS解析
   >
   > 直连代理服务器ip

3. 直接请求IP地址会有什么问题吗

   > https://juejin.im/post/5d2d8928f265da1b95708b97

4. http和https区别，http的加密过程，Get和Post



#### 项目质量

1. 有哪些crash，如何捕捉crash，解决crash

   | crash类型                                                    | 防护               |
   | ------------------------------------------------------------ | ------------------ |
   | unrecognized selector to instance                            | 消息转发机制       |
   | 可变数据 copy之后不可变引起的unrecognized selector to instance | 消息转发机智       |
   | 分类的属性未实现setter、getter方法                           | 重新实现           |
   | not key value coding-compliant for the key                   | 消息转发机制       |
   | EXC_Bad-ACESS KVO 监听者已经释放了，被监听者触发KVO未正确移除 | 监听者释放移除KVO  |
   | __boundsFail: index 2 beyond bounds                          | 方法交换容错       |
   | -[__NSArrayM insertObject:atIndex:]: object cannot be nil    | 方法交换容错       |
   | CFRelease EXC_Bad-ACESS 多线程调用setter                     | 加锁或者不同数据   |
   | NSInternalInconsistencyException couldn't find a common superview | autolayout无父view |
   | nan数据使用                                                  |                    |
   | Can't add self as subview                                    | 方法交换           |
   | session.cache OOM                                            |                    |
   | nil string parameter : NSURL NSMutableAttributeString        | 方法交换           |
   |                                                              |                    |
   |                                                              |                    |

2. wkwebview做过哪些优化处理

3. bad access是怎么发生地，如何调试解决，zombie object是如何实现的

   > Edit Scheme -> Diagnostics -> Zombie Objects
   >
   > 系统开启僵尸对象检测后不会释放该对象所占用的内存，只是释放了与该对象所有的相关引用
   >
   > 系统在回收对象时，可以不将其真的回收，而是把它转化为僵尸对象。这种对象所在的内存无法重用，因此不可遭到重写，所以将随机变成必然。
   >
   > 系统会修改对象的 isa 指针，令其指向特殊的僵尸类，从而使该对象变为僵尸对象。僵尸类能够相应所有的选择器，响应方式为：打印一条包含消息内容及其接收者的消息，然后终止应用程序。

4. 如何实现无用类的检测

   > fui原理
   >
   > appcode工具

5. 优化的指标维度，GPU帧率怎么度量，光栅化的细节，线上监控怎么做等。

6. 若webview不显示但加载了一个网页，原生截图是否算离屏渲染？如何检测是否发生离屏渲染。

7. App启动流程优化

8. App包大小优化

9. App卡顿优化