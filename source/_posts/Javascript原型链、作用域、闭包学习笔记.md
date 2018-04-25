---
title: Javascript原型链、作用域、闭包学习笔记
date: 2018-04-25 22:21:25
tags:
 - Javascript
categories:
 - 前端
 - Javascript
---

### 数据类型
* 值类型 boolean undefined string number
* 引用类型 Object null function array

#### 类型判断
值类型 typeof
引用类型 instanceof

```
var fn = function(){}
console.log(fn instanceof Object) // function

var foo = "hello"
console.log(typeof foo) // string

console.log(typeof null) // object

但是：
null instanceof Object === false

// null 为object是javascript遗留的一个bug
```

### 对象

__Tip：一切引用类型都是对象，对象是属性的集合__


对象是通过函数创建的：
```
var object = {a: 1, b:1} // 语法糖
```

真实情况：
```
var object = new Object();
object.a = 1;
object.b = 1;

console.log(typof Object) // function
```


### 原型 prototype
函数是一种对象，每个函数都有一个默认的属性：prototype
这个prototype的值是一个对象（属性的集合）， 默认只有一个constructor的属性，指向这个函数本身

```
var Fn = function(){}
Fn.prototype.name = "hello"
Fn.prototype.foo = function(){}
var fn = new Fn()
```

Fn是一个函数，fn是通过Fn new出来的，这样fn对象就可以访问Fn.prototype中的属性
（问：不new就访问不了？是，但是为什么要new？是不是相当于类和类的实例）

\__proto\__是隐式属性，这个属性引用了创建这个对象的函数的prototype, 即：
```
fn.__proto__ === Fn.prototype
```

每个函数都有一个prototype原型，每个对象都有一个\__proto\__隐式原型
(javascript 不希望开发者用到这个__proto__)

每个对象都有一个\__proto\__属性，指向创建该对象的函数的prototype

**Object.prototype 的\__proto\__指向null**


```
var o = new Foo();
```
JavaScript 实际上执行的是：

```
var o = new Object();
o.__proto__ = Foo.prototype;
Foo.call(o);

function Foo(){}
var fn = new Foo
console.log(fn instanceof Foo) // true
```

### instanceof
Instanceof 查找规则
Instanceof运算符的第一个变量是一个对象，暂时称为A；第二个变量一般是一个函数，暂时称为B。

**Instanceof的判断规则是：沿着A的\__proto\__这条线来找，同时沿着B的prototype这条线来找，如果两条线能找到同一个引用，即同一个对象，那么就返回true。如果找到终点还未重合，则返回false**

Instanceof 表达的是一种继承关系，或者原型链的结构
```

function Fn(){}

var fn = new Fn()

fn.a = 10

Fn.prototype.a = 100
Fn.prototype.b = 200

console.log(fn.a)
console.log(fn.b)
```
fn是通过Fn new过来的，a是fn的基本属性，b从Fn.prototype得来，因为fn.\__proto\__指向是Foo.prototype

### 原型链
**访问一个对象属性时，先从基本属性上查找，如果没有再沿着\__proto\__这条链往上找，这就是原型链**

判断一个属性是基本属性还是从原型链上查找的，用hasOwnProperty

对象的方法都可以通过prototype扩展

### 上下文环境
Javascript准备工作：

变量、函数表达式  => 变量的声明，默认赋值为undefined （后期在执行过程中赋值）

this  => 赋值 this无论哪个情况都有值，至于值是什么，跟上下文环境有关

函数声明 => 赋值

函数体的执行上下文需要附加
参数 =》 赋值
arguments => 赋值
自由变量的取值作用域 => 赋值

Javascript 在执行一段代码前都会进行一些准备工作来生成执行上下文，这个代码段分三种情况：全局环境，函数体，eval

代码段就是一段文本形式的代码
```
// 全局：
<script>
alert('123')
</script>

// eval:
eval("alert('123')")

// function :
var fn =new Function("x", "console.log(x)")
```
__函数每被调用一次，都会产生一个新的执行上下文环境__
__函数在定义的时候（不是调用的时候），就已经确定了函数内部自由变量的作用域__

__自由变量：__
在A作用域中使用的变量x，却没有在A作用域中声明（其他作用域中声明的），对于A作用域来说，x就是一个自由变量。

```
var a = 10

function fn() {
console.log(a) // 是自由变量 函数创建时就确定了a要取值的作用域
                        // 下级作用域可以获取上级作用域的变量，反之不行
}

function bar(f) {
var a = 20
f() // 10 而不是20
}

bar(fn)
```
执行上下文环境通俗定义：在执行代码之前，把将要用到的所有的变量都事先拿出来，有的直接赋值，有的先用undefined占个空

__js在代码执行过程中，会有数不清的函数调用，每个函数调用会产生多个上下文环境，这么多的上下文环境需要管理，销毁而释放内存（上下文环境执行栈）__

### this
this在函数中到底取何值，是在函数真正被调用的时候确定的，函数定义的时候确定不了，因为this的取值是执行上下文环境的一部分，每次调用函数，都会产生一个新的执行上下文环境。

this取值一共分四种情况：

__构造函数__
构造函数是用来new对象的函数，第一个字母大写
```
function Foo() {
this.name = "test"
console.log(this)
}

var fn = new Foo()
fn.name // test
```
以上this为即将new出来的对象的

但是如果直接把Foo作为函数调用,this就是window


__函数作为对象的一个属性__
如果函数作为对象的一个属性时，并且作为对象的一个属性被调用时，函数的this指向该对象。
```
var obj = {
    x: 10,
    fn: function() {
        console.log(this, this.x)
    }
}

ojb.fn() // this指向obj对象
```
如果不是作为obj被调用
```
var fn1 = obj.fn

fn1()
```
那么this就是指向window，this.x为undefined

__函数使用call apply调用__

当用call apply调用时，this指向被传入的对象
```
var obj = {
x: 10
}

var fn = function() {
console.log(this)
console.log(this.x)
}

fn.call(obj)
```

__全局&调用普通函数__
console.log(this === window) true

普通函数在调用时，其中的this也都是window


### 执行上下文栈
```
执行上下文栈
                        压栈                        出栈（销毁）
全局上下文环境 =》 函数上下文环境 =》 全局上下文环境
                                全局上下文环境
```

代码段：
```
var a = 10,
        fn,
        bar = function(x) {
            var b = 5
            fn(x + b) // 进入fn全局上下文环境
        }


fn = function(y) {
    var c = 5
    console.log(y+c)
}

bar(10)// 进入bar上下文环境

```
在执行代码之前将创建全局上下文环境


### 作用域
Js没有块级作用域，就是{}中间的语句 例如if for这些
所以要一开始声明变量 避免歧义

__JS除了全局作用域外，只有函数可以创建的作用域__

__作用域在函数定义的时候就已经确定，而不是调用的时候。（同一个作用域有不同的上下文执行环境）（this取值是函数调用的时候确定的）__

__如果要查找一个作用域下某个变量的值，就需要找到这个作用域下对应的执行上下文环境，再在其中寻找变量的值__

自由变量的取值要到创建这个变量的环境去取，而不是调用（静态作用域）。

__如果在全局没找到，则未定义。如果是函数作用域，则去创建该函数的作用域去找__

### 闭包

两种应用情况：

__1，函数作为返回值__

```
function fn(){
// 这里当执行完fn的时候，按道理讲应该销毁fn上下文执行环境，但是fn的返回值是一个函数（函数可以创建一个独立的作用域），而这个函数中也引用了max变量，所以max不能被销毁，销毁之后bar函数就找不到max的值了
    var max = 10
    
    return function(x) {
        if (x > max) {
        console.log(x)
        }
    }
}

var f1 = fn()，
max = 100

f1(15)  // 15 这里取值15证明fn的上下文环境没有被销毁，否则按照作用域链来说，max可以取到全局作用域中的值100
```

__2， 函数作为参数__
```
var max = 10;

var fn = function (x){
    if (x > max) {
        console.log(x)
    }
}

(function(f){
    var max = 100
    f(15)
})(fn)
// max取值为10 （去创建这个函数的作用域取值）
```

__普通函数别调用完之后，其执行上下文环境将被销毁，其中的变量也会被同时销毁。但是在闭包中，其上下文执行环境不会被销毁__

作用域和上下文执行环境：
作用域在函数定义的时候就已经确定，一个函数只有一个作用域，但是随着被调用的不同，会有多种上下文环境

### 参考学习
学习自：[http://www.cnblogs.com/wangfupeng1988/p/3977924.html][1]

__注：这个非常不错，墙裂推荐学习__

  [1]: http://www.cnblogs.com/wangfupeng1988/p/3977924.html 
