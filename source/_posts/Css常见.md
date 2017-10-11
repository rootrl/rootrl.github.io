---
title: Css常见
date: 2017-10-11 03:16:48
tags:
 - Css
 - 前端
categories:
 - 前端
 - CSS
banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/css.jpg
---

## 定位
position属性：static、relative、absolute、fixed、sticky、inherit
* static(默认)：元素框正常生成。块级元素生成一个矩形框，作为文档流一部分，行内元素则会创建一个或多个行框，置于其父元素中。
* relative：元素相对于之前正常文档流中的位置发生偏移，并且原先位置仍然被占据。发生偏移的时候，可能会覆盖其他元素。
* absolute: 元素不再占文档流位置，并且相对于包含块进行偏移（包含块为最近一级外层元素position不为static的元素）
* fiexd 元素不再占据文档流位置，并且当对于视窗进行定位
* sticky Css3新增属性，粘性定位，相当于relative和fiexed混合，最初被当作是relative，相对于原来的位置进行偏移；一旦超过一定阈值后，会被当成fixed定位，相对于窗口进行定位。
* inherit为从父元素继承
其中偏移量有top、right、bottom、left四个属性。其单位有像素、百分比也可以是相对的单位比如rem等。
## 尺寸
我们一般布局中使用的尺寸单位除了px还可以包含以下单位：
* 百分比：百分比的参照物是父元素，50%相当于父元素的50%
* rem: 这个当对于复杂的设计图相当有用，它是html font-size的大小。
* em：也是一个当对单位，相对于父元素的font-size，但是由于计算太麻烦，并不常用。
## 盒子模型
每个元素会形成一个矩形框，主要包括margin(外边距)+border(边框)+padding(内边距)+content(内容)
Css中存在两种不同的盒子模型：标准W3C盒子模型和IE盒子模型。两种盒子模型差别主要体现在盒子的宽度，标准盒子模型中：width = content宽度，IE盒子模型中width = content + padding + border
所以：
标准盒子模型的盒子宽度：左右margin + 左右border  + padding + width
IE盒子模型的盒子宽度 = 左右marin + width
我们可以通过css3的属性box-sizing设置不同的模型。值为content-box即为标准盒子模型，值为content-border即为IE盒子模型。
## 浮动
浮动最初只是被用来实现文字环绕的特效，只是我们后来把它用来布局。
我个人是很反感float的，一般会用diaply:inline-block特性来实现布局，完全可以替代float。或是后来flex等等。
深入浮动详见：[CSS float浮动的深入研究、详解及拓展(一)][1] 系列

## 布局
布局实现方式有很多种，基于定位、浮动等等，但是我这里推荐display:inline-block代替float布局，移动端直接flex

  [1]: http://www.zhangxinxu.com/wordpress/2010/01/css-float%E6%B5%AE%E5%8A%A8%E7%9A%84%E6%B7%B1%E5%85%A5%E7%A0%94%E7%A9%B6%E3%80%81%E8%AF%A6%E8%A7%A3%E5%8F%8A%E6%8B%93%E5%B1%95%E4%B8%80/

