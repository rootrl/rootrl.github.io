---
title: Flex Layout
date: 2017-10-13 10:11:37
tags:
 - 前端
 - CSS
 - Flex
categories:
 - 前端
 - CSS

banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/flex.png
---
## 简介
Flex是Flexible Box的缩写，意为弹性布局。是W3C在2009年提出的一个新的布局方案。可以方便的实现各种页面布局。目前浏览器兼容如下：
![Flex support][1]

Flex在移动端开发上已是主流，比如H5页面，微信小程序等等。

## Why Flex
传统的布局方案主要基于CSS盒子模型，依赖Display、Position、Float等属性。但是它对于一些特殊布局非常不方便，比如水平垂直居中。传统方式实现起来非常繁杂，各种黑科技，比如以下是一种水平垂直居中的实现方式：

基础的DOM如下，一个父元素是宽高为500px的红色容器，包裹着宽高为100px的黄色子容器：
```
<style>
	* {
		margin: 0;
		padding: 0;
	}

	.dad {
		background-color: red;
		width: 500px;
		height: 500px;
	}

	.son {
		background-color: yellow;
		width: 100px;
		height: 100px;
	}
</style>

<div class="dad">
	<div class="son">
		
	</div>
</div>
```

现要实现子元素在父元素中水平垂直居中，传统的方式如下，基于定位。
```
.dad {
    position: relative;
}

.son {
    position: absolute;
    margin: auto;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
}

```

而Flex只需几行代码搞定，非常方便：
```
.dad {
    display: flex;
    justify-content: center;
    align-items: center
}
```

## 使用
任何一个容器都可以指定为Flex布局。
```
.box {
	display: flex;
}
```

行内元素也可以使用Flex布局：
```
.box {
	display: inline-flex
}
```
Webkit内核的浏览器需加上-webkit前缀。

注意：
设为Flex布局后，子元素的float、clear、vertical-alian属性都将失效。

## 基本概念
父容器设为flex后，它的所有子元素自动成为容器成员（这里加入我的理解，如果不对请指出：这里的子元素不论什么元素，块级还是行内，而且只作用于子元素，孙元素不起作用，需继续在子元素上设置display:flex）

Flex的基本概念就是容器和轴，容器包括外层的父容器和内层的子容器（也叫项目，flex item），轴包括主轴和交叉轴。

如图：
![Flex container][2]

容器默认存在两根轴，水平的主轴(main axis)和垂直的交叉轴（cross axis）。主轴的开始位置（与边框的交叉点）叫做main start，结束位置叫做main end；交叉轴的开始位置叫做cross start，结束位置叫做cross end。

子容器（项目）默认沿主轴排列，单个项目占据的主轴空间叫做main size，占据的交叉轴空间叫做cross size。

Flex布局主要涉及12个属性（不含display:flex），其中容器和子容器各6个，但是平常使用到的基本只有4个属性，父容器和子容器各2个。

作用于父容器的属性：
* flex-direction
* flex-wrap
* flex-flow
* justify-content
* align-items
* align-content

作用于子容器（项目）的属性：
* order
* flex-grow
* flex-shrink
* flex-basis
* flex
* align-self

## 详细介绍

### 容器属性

#### flex-direction
flex-direction属性决定主轴的方向，及子容器（项目）的排列方向。

```
.box {
  flex-direction: row | row-reverse | column | column-reverse;
}
```

可能的值：
* row（默认值）：主轴为水平方向，起点在左端。
* row-reverse：主轴为水平方向，起点在右端。
* column：主轴为垂直方向，起点在上沿。
* column-reverse：主轴为垂直方向，起点在下沿。

如图：
![Flex direction][3]

#### flex-wrap
默认情况下，项目都排在一条线（又称"轴线"）上。flex-wrap属性定义，如果一条轴线排不下，如何换行。

```
.box {
  flex-wrap: nowrap | wrap | wrap-reverse;
}
```

可能的值：
* nowrap（默认）：不换行
* wrap：换行，第一行在上方
* wrap-reverse: 换行，第一行在下方

#### flex-flow
flex-flow属性是flex-direction和flex-wrap属性的简写形式，默认为：row nowrap

```
.box {
	flex-flow: <flex-direction> || <flex-wrap>
}
```

#### justify-content
justify-content定义了项目在主轴上的对齐方式。

```
.box {
	justify-content: flex-start| flext-end | center | space-between |space-around; 
}
```

它可能取5个值，具体对齐方式与轴的方向有关。下面假设主轴为从左到右。
* flex-start（默认值）：左对齐
* flex-end：右对齐
* center： 居中
* space-between：两端对齐，项目之间的间隔都相等。
* space-around：每个项目两侧的间隔相等。所以，项目之间的间隔比项目与边框的间隔大一倍。

如图：
![Justify content][4]
#### align-items
align-items属性定义了项目在交叉轴上的对齐方式：

```
.box {
	align-items: flex-start| flex-end | center | baseline | strech
}
```

它可能取5个值。具体的对齐方式与交叉轴的方向有关，下面假设交叉轴从上到下：

* flex-start：交叉轴的起点对齐。
* flex-end：交叉轴的终点对齐。
* center：交叉轴的中点对齐。
* baseline: 项目的第一行文字的基线对齐。
* stretch（默认值）：如果项目未设置高度或设为auto，将占满整个容器的高度。

如图：
![Align items][5]
#### algin-content
align-content属性定义了多根轴线的对齐方式。如果项目只有一根轴线，该属性不起作用。

可能的值：
* flex-start：与交叉轴的起点对齐。
* flex-end：与交叉轴的终点对齐。
* center：与交叉轴的中点对齐。
* space-between：与交叉轴两端对齐，轴线之间的间隔平均分布。
* space-around：每根轴线两侧的间隔都相等。所以，轴线之间的间隔比轴线与边框的间隔大一倍。
* stretch（默认值）：轴线占满整个交叉轴。

如图：

![Align items][6]

### 项目属性
#### order
order属性定义项目的排列顺序。数值越小，排列越靠前，默认为0，
```
.item {
	order: <integer>
}
```

#### flex-grow
flex-grow属性定义项目放大比例，默认为0，即如果存在剩余空间，也不放大。

```
.item {
	flex-grow: <number> /* default 0 */
}
```

如果所有项目的flex-grow属性都为1，则它们将等分剩余空间（如果有的话）。如果一个项目的flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。

#### flex-shrink
flex-shrink属性定义了项目的缩小比例，默认为1，即如果空间不足，项目将缩小。

```
.item {
	flex-shrink: <number> /* default 1 */
}
```

如果所有项目的flex-shrink属性都为1，当空间不足时，都将等比例缩小。如果一个项目的flex-shrink属性为0，其他项目都为1，则空间不足时，前者不缩小。
负值对该属性无效。

#### flex-basis

flex-basis属性定义了在分配多余空间之前，项目占据的主轴空间（main size）。浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即项目的本来大小。

```
.item {
	flex-basis: <length> | auto; /* default auto */
}
```

它可以设为跟width或height属性一样的值（比如350px），则项目将占据固定空间。

####flex
flex属性是flex-grow, flex-shrink 和 flex-basis的简写，默认值为0 1 auto。后两个属性可选。

该属性有两个快捷值：auto (1 1 auto) 和 none (0 0 auto)。
建议优先使用这个属性，而不是单独写三个分离的属性，因为浏览器会推算相关值。

#### algin-self
align-self属性允许单个项目有与其他项目不一样的对齐方式，可覆盖align-items属性。默认值为auto，表示继承父元素的align-items属性，如果没有父元素，则等同于stretch。
```
.item {
	algin-self: auto | flex-start | flex-end| center | baseline | stretch
}
```

该属性可能取6个值，除了auto，其他都与align-items属性完全一致。

## 布局实战

#### 基本网格布局
最简单的网格布局，就是平均分布。在容器里面平均分配空间。

比如实现如图布局：
![Grid布局][7]


Html代码:
```
	<div class="grid">
		<div class="grid-cell">cell1</div>
		<div class="grid-cell">cell2</div>
		<div class="grid-cell">cell3</div>
	</div>
	<div class="grid">
		<div class="grid-cell">cell1</div>
		<div class="grid-cell">cell2</div>
	</div>
```

Css代码：

```
	.grid {
		display: flex;
	}

	.grid-cell {
		flex: 1; /* 即为flex-grow: 1; */
		border: green solid 1px; /* 可选，加边框保证例子效果 */
	}
```

#### 百分比布局
某个网格宽度为固定百分比布局，其余网格平均分配剩余空间。

如图：
![此处输入图片的描述][8]

Html代码：
```
	<div class="grid">
		<div class="grid-cell cell-1of2">dsfdsf</div>
		<div class="grid-cell">dsfsdf</div>
		<div class="grid-cell">sdfsdf</div>
	</div>


	<div class="grid">
		<div class="grid-cell cell-1of3">dsfdsf</div>
		<div class="grid-cell">dsfsdf</div>
		<div class="grid-cell">sdfsdf</div>
	</div>

	<div class="grid">
		<div class="grid-cell cell-1of4">dsfdsf</div>
		<div class="grid-cell">dsfsdf</div>
		<div class="grid-cell">sdfsdf</div>
	</div>
```

Css代码：
```
	.grid {
		display: flex;
	}

	.grid-cell {
		flex: 1;
		border: red solid 1px;
	}

	.cell-full {
		flex: 0 0 100%;	
	}

	.cell-1of2 {
		flex: 0 0 50%;
	}

	.cell-1of3 {
		flex: 0 0 33.3333%;
	}

	.cell-1of4 {
		flex: 0 0 25%;
	}
```

#### 圣杯布局
圣杯布局（Holy Grail Layout）指的是一种最常见的网站布局。页面从上到下，分成三个部分：头部（header），躯干（body），尾部（footer）。其中躯干又水平分成三栏，从左到右为：导航、主栏、副栏。

![百分比布局][9]

Html代码：
```
<body class="holy-grid">
	<header class="holy-grid-items">#header</header>
	<div class="holy-grid-content holy-grid-items">
		<div class="holy-grid-content-items holy-grid-content-left">
			# left
		</div>
		<div class="holy-grid-content-items holy-grid-content-center">
			# center
		</div>
		<div class="holy-grid-content-items holy-grid-content-right">
			# right
		</div>
	</div>
	<footer class="holy-grid-items">#footer</footer>
</body>
```

Css代码如下：
```
	* {
		margin: 0;
		padding: 0;
	}

	.holy-grid {
		display: flex;
		flex-direction: column;
		min-height: 100vh; /* 相对于视口的高度。视口被均分为100单位的vh */
	}

	header, footer {
		text-align: center;
		flex: 0 0 100px;
	}

	.holy-grid-content {
		display: flex;
		flex: 1;
	}

	.holy-grid-content-items {
		flex: 1;
	}

	.holy-grid-content-left {
		flex: 0 0 150px;
	}

	.holy-grid-content-right {
		flex: 0 0 150px;
	}
```

好了，flex就到这里了，本内容主要参考后面参考部分的教程，文章并不是简单搬过来的，而是理解后在写的，例子也是自己在理解后，然后动手写，再消化明白后才写出来的。

今天一天都在搞这篇文章，现在Flex算是入门了。。

## 参考
Flex 布局教程：语法篇 [http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html][10]
一劳永逸的搞定 flex 布局 [https://juejin.im/post/58e3a5a0a0bb9f0069fc16bb][11]


  [1]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/flex-surport.jpg
  [2]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/container.png
  [3]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/flex-direction.png
  [4]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/justify-content.png
  [5]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/align-items.png
  [6]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/align-content.png
  [7]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/grid.png
  [8]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/grid-percent.png
  [9]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/holy-grid.png
  [10]: http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html
  [11]: https://juejin.im/post/58e3a5a0a0bb9f0069fc16bb
