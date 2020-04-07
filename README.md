# flutter_toolkit

Language: 中文简体 | [English](README-EN.md)

## 介绍

- 这是一个使用Flutter编写的工具箱，其中的少量功能目前也能在mac/linux工作，致力于打造全平台的工具箱，希望能够将所有能归纳成工具的功能以最小的代码集成与其中，也是作者的初心。
- 是作为我学习Flutter的一个成果，以及不断通过编写代码来提升自己的一个工具。

## 功能列表

- 常用功能(开启远程ADB调试，查看WIFI密码，电量伪装，MAC地址修改...)
- 文件管理器(能同时运行在Android/Linux/Mac的文件管理器，已具有简单的功能，并集成Apktool)
- ROM工具(能够处理Android ROM的工具，该页面不开源)
- 远程控制(能够控制局域网内的其他安卓设备，并实时投屏，目前该功能仍有缺陷)
- Niterm(一个终端模拟器，使用传统终端的思路创建)
- 应用管理(开发中...)
- 阴影截屏(能够生成已有截图的阴影截屏，将来或将支持带壳截屏)
- 数据线刷机(能够通过数据线给另一部安卓手机刷机，原理已经实现，但无时间维护)
- NiSSH(类似于JuiceSSH，win端的Xshell)

## 下载使用
[酷安首页](https://www.coolapk.com/apk/com.nightmare)

## 已开源列表
- [ ] 常用功能
- [x] 文件管理器
- [ ] 远程工具
- [x] 终端模拟器
- [ ] 阴影截屏
- [ ] 数据线刷机
- [ ] NiSSH
## 问题？

### 1.为什么还没有完全开源?

时间没有分过来，除Rom页面都是会开源的。

### 2.为什么项目中有那么多的垃圾代码?

在项目早期(作者大一上学期的时候)，写了一些垃圾代码，到现在整个项目1w多行代码，仍留有些早期的代码，作者也没有留意哪些部分还存在自己无心留下的垃圾代码

如果你看到类似于```int a``` ```Widget a``` 类似的代码，你可以在issue中提示我优化。

### 3.是否还会继续维护?

直到我工作时(初步估计两年后)，我都会一直维护这个工具箱，修复现有的bug以及新功能的开发，这都大量消耗量我的空余时间，如果你愿意对此储存库做出任何共享，实在感激不尽！

## 最后

迫于生活上带来的压力，我的时间将异常的紧迫，目前是普通大学大二的学生，这个工具箱的开发也付出了我大学中大量的时间，虽然其中待优化的地方实在太多，但我依然将其开源，希望其中有能供大家使用的地方，其中一些已有的问题我也有优化的思路，希望之后我能多抽出时间对其进行优化