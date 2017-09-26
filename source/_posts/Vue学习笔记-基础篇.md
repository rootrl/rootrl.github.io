---
title: Vue学习笔记 - 基础篇
date: 2017-09-26 09:22:52
tags:
 - Javascript
 - Vue
categories:
 - 前端
 - 框架
 - Vue
banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/vue-logo.png
---
先是把官方手册一字不落过一遍，有例子要动手写，写的时候不要复制代码，而是把例子看几遍，记住思想，然后自己写代码实现。有的语法糖记不住的可以看看。然后例子不是说跑通就好了，多多变通下。然后进行多个维度思考。

## Hello

```
<div id="demo">{{message}}</div>

<script>
     var app = new Vue({
          el: "#demo",
          data: {
               message:  "Hello Vue"
          }
     });
</script>
```
思考：这里可以看到Html部分的"{{message}}"的书写方式，这肯定是模板语法了，可以猜测到message是个变量，注意双花括号的书写方式，然后思考下假如在元素的属性上写一个变量改怎么写，比如 class = "active"， 这里active是一个变量，而如果用常规字符串符号包裹，这种书写肯定是错误的，改怎么写呢？这里得看接下来的Vue指令部分了。
然后Js部分可以看到实例化了一个Vue然后赋给app（可以试着打印app，看有哪些属性），注意Vue实例中的属性“el”“data”这些，猜测下作用。然后想想肯定还有其他更多属性的。
这里data里面的message肯定就是对应模板中的那个message了，Vue手册说这里是做响应式的数据绑定的，改变了这里的message，模板中也会相应改变，而且data中的每一个属性都会注册到上层的app变量中，也就是app.message == app.data.message，然后我们试着在console面板中改变message的值，看看变化。但是如果我们在后面在声明一个data，比如app.v = 2，这里的v就不是响应式的了，我们可以用Vue.set(app.a, 属性名，值)，方式赋值，这时v就是响应式的了。

## 包括指令和For循环的例子
```
<div class="demo">
    <ul>
        <li v-for="item in items" v-bind:item="item">
            name:{{item.name}}, age {{item.age}}
        </li>
    </ul>
</div>

<script>
    var app = new Vue({
        el: ".demo",
        data: {
            items: [
                {name: "Rootrl", age: 26},
                {name: "Mancy", age: 1},
                {name: "Katol", age: 26}
            ]
        }
    });
</script>
```
思考：这里首先可以看到解开了我们上个实例的疑惑了，在dom属性下的变量绑定方式是用v-bind:属性名 = "变量"这种形式，这就是所谓的Vue指令了，然后看看for的书写方式，很平常，但要记住。在手册上可以了解到遍历对象时获取值、key、索引的方式是v-for="(value, key, index) in items"，这个以后肯定会用到。

## 组件
```
<ul class="demo">
    <family v-for="(item, key, index) in items" :item="item" :key="index"></family>
</ul>

<script>
    // 注意：组件是Vue全局变量提供的，且需提前定义（在app实例前）
    Vue.component("family", {
        props: ['item'],    // 传值
        template: "<li>name: {{item.name}}, age: {{item.age}}</li>"
    });

    var app = new Vue({
        el: ".demo",
        data: {
            items: [
                {name: "Rootrl", age: 26},
                {name: "Mancy", age: 1},
                {name: "Katol", age: 26}
            ]
        }
    });
</script>
```
思考：首先看dom部分，组件相当于自定义的一个html5元素（所以注意兼容性，其实是废话=='），然后用到了我们上个实例提到的获取索引等书写方法，还有这里的key属性是必须写的，为啥？（首先我忘了写过，console会有报错）。
再看看Js部分，注意看是怎么声明一个组件的，这里用到了暴露在外面的Vue全局变量提供的component方法，注意看书写方式，这里的props作用很大，用来传值以及父子组件通信。接下来还是那个带data的常规实例化，注意组件定义得在app实例化前面（因为我开始放后面还是有报错==）

## 事件
```
<div class="demo" v-on:click="++counter">点击我, 次数{{counter}}</div>
<script>
    var app = new Vue({
        el: ".demo",
        data: {
            counter: 1
        }
    });
</script>
```
思考：也是用到了v指令，只用记住一个书写方式就行了，其他形式到时候手册查，还有这里后面的值可对变量用一些简单单表达式，复杂的就不行了，那么一个事件所要做的事通常有很多，该咋办呢？很简单，我们在第一个例子中说到除了el, data这些属性外，Vue中可能还有其他的，这里便用到了，叫method。

```
<div class="demo" v-on:click="handler('hi', $event)">点我 {{message}}</div>
<script>
    var app = new Vue({
        el: ".demo",
        data: {
            message: "hello"
        },
        methods: {
            handler: function(data, event) {
                this.message = data;
                alert(this.message);
            }
        }
    });
</script>   
```
思考：这里vue指令绑定了click事件，点击会触发handler方法，handler方法里，首先这个event是javascript的原生dom事件（方法默认接受的就是event，我这里故意放到第二个，然后注意把原生event传过来的书写方式），这里改变message是直接操作this.message，this在这里是指Vue实例。说到这里的this，官方手册在开头有说到不要在回调或属性中用箭头函数，箭头函数中父子上下文是绑定在一起的，到时候就不一定是预期的this了。

## v-model 双向数据绑定
```
<div class="demo">
    {{message}} <br>
    <input type="text" v-model="message">
</div>

<script>
    var app = new Vue({
        el: ".demo",
        data: {
            message: "hello"
        }
    });
</script>

```
这个例子就是Two-way-data-binding 双向数据绑定，双向数据绑定就是属性在model层变化了UI层也要变化，反过来UI层面元素的变动也要反馈到Model层。Vue底层是通过Object.defineProperty()来劫持各个属性的setter，getter来达到这个效果的（defineProperty要IE9以上才支持）。回到dom层面，这里只是input，再注意下check，select等的写法。

## 深入组件
组件可以提高代码复用性，Vue官网提到一点“组件也可以是原生HTML元素的形式，以is特性扩展”（什么意思？这个先记着）。

### 使用组件
在实例前使用Vue.component(tagName,  options)注册组件。
```
 Vue.component('my-component',  {
     // 选项
});
```

在实例的模块中可以使用<my-component></my-component>形式调用。

### DOM模板解析注意事项
当使用DOM作为模板时，将会受到Html的限制，因为浏览器只有在解析标准化HTML后才能获取模板内容，比如ul, ol, table，select限制了能被他包括的元素。
```
<table>
  <my-row>...</my-row>
</table>
```
比如这里的my-row被认为是无效的，在渲染的时候会导致错误。这里就要使用开头提到的那个is了：
```
<table>
  <tr is="my-row"></tr>
</table>
```

### data 必须是函数
组件中的data必须是函数，这个要注意下。


### 组合组件
在Vue中，父子组件的关系可以总结为props dwon, events up，父组件通过props向下传递数据给子组件，子组件通过events给父组件发送消息。

组件实例中的作用域是孤立的，这意味着不能在子组件中直接引用父组件的数据，要让子组件使用父组件的数据，我们需要通过子组件的props选项：
```
Vue.component('child', {
     props: ['message'],
     template: '<span>{{message}}</span>'
})

// 使用时直接传递值
<child message="hello"></child>
```

### 自定义事件
父组件可以通过props传递数据给子组件，但是子组件怎么跟父组件通信呢？这时候Vue的自定义事件系统就可以派得上用场了。

Vue实例事件接口：

* 使用$on(eventName) 监听事件
* 使用$emit（eventName）出发事件

注意vue的事件系统和浏览器的eventTarge api不同。$on和$emit不是addEventListener 和 dispatchEvent的别名。

父组件可以在使用子组件的地方使用v-on来监听子组件触发的事件。

```
<div id="counter-event-example">
  <p>{{ total }}</p>
  <button-counter v-on:increment="incrementTotal"></button-counter>
  <button-counter v-on:increment="incrementTotal"></button-counter>
</div>

<script>
    Vue.component('button-counter', {
      template: '<button v-on:click="incrementCounter">{{ counter }}</button>',
      data: function () {
        return {
          counter: 0
        }
      },
      methods: {
        incrementCounter: function () {
          this.counter += 1
          this.$emit('increment')
        }
      },
    })
    new Vue({
      el: '#counter-event-example',
      data: {
        total: 0
      },
      methods: {
        incrementTotal: function () {
          this.total += 1
        }
      }
    })
</script>
```
在本例中，子组件已经和他外部完全解耦了。他所做的只是报告自己的内部事件，至于父组件是否关系则与他无关。

分析：这里确是解耦了，子组件只负责做自己的事，并提供一个increment 事件给父组件。父组件监听子组件触发的increment事件，然后触发实例提供的incrementTotal方法。这里只是子组件$emit触发，父组件$on监听，其他的各做自己的事。

### 修饰符和原生事件
类似v-on:click.native="doSomething"后面的这个.native就是Vue的修饰符，比如这里通过.native在某个组件上监听一个原生事件。

### 非父子组件通信
两个非父子组件通信可以使用一个空的Vue实例作为中央事件总线:
```
var bus = new Vue();

// 触发组件A中的事件
bus.$emit('id-selected', 1);

// 在组件B创建的钩子中监听事件
bus.$on('id-selected', function(id){
     // ...
});
```

### 杂项
Vue组件的API来自三部分，Props，Events和slots

* Props允许外部环境传递数据给组件
* Events允许从外部环境在组件内触发副作用
* Slots允许外部环境将额外的内容组合在组件中


Slots插槽这部分没深入，具体结合业务场景使用。

#### 子组件索引
有时候需要在Javacript中直接访问子组件时，需要使用ref为子组件指定一个索引Id:

```
<div id="parent">
  <user-profile ref="profile"></user-profile>
</div>

<script>
    var parent = new Vue({ el: '#parent' })
    // 访问子组件
    var child = parent.$refs.profile
</script>
```
#### 异步组件
需与webpack结合，后面再深入

## 总结
这样Vue文档基础部分就走马观花过了一遍了，其中某些特性这里跳过了，具体的得结合具体使用场景再理解。
其中组件、组件间通信这个是重点，得好好理解，其次是Vue指令这些语法糖等。
总的来讲就是通过实例化Vue来声明绑定一些属性，这些属性都有各自作用，比如el绑定模板中的Vue实例作用元素，data提供数据，method提供方法等。然后暴露在全局的Vue也提供了许多方法以供使用，比如component。

接下来会深入Vue部分，比如使用构建工具webpack、路由、状态管理等等。


