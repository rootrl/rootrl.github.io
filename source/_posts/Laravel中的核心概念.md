---
title: Laravel中的核心概念
date: 2018-06-13 18:33:53
tags:
 - PHP
 - Laravel

categories:
 - 开发语言
 - PHP

---

## 导言
Laravel是一款先进的现代化框架，里面有一些概念非常重要。在上手Laravel之前，我认为先弄懂这些概念是很有必要的。你甚至需要重温下PHP OOP知识。我相信很多人对比如getter setter以及__invoke、__call、__callStatic这些魔术方法甚至this、
self、static这些关键字作用都还是很模糊的（我上一个老大喜欢问这种基础问题，然后答不上来-_-'）。


## DI & IoC

首先名词解释，DI全称是Dependency injection，依赖注入的意思。而IoC是Inversion of control 控制反转。

要了解依赖注入和控制反转，首先我们不得不提到面向对象设计中的五大设计原则：S.O.L.I.D。

#### S.O.L.I.D - 面向对象五大设计原则

SRP   The Single Responsibility Principle 单一责任原则
OCP   The Open Closed Principle 开放封闭原则
LSP   The Liskov Substitution Principle    里氏替换原则
ISP   The Interface Segregation Principle    接口分离原则
DIP   The Dependency Inversion Principle    依赖倒置原则

这五种思想原则对我们平常的软件开发设计非常重要，大家可以具体去了解下。

#### 依赖倒置原则

这里我们重点讲下依赖倒置原则：实体必须依靠抽象而不是具体实现。它表示高层次的模块不应该依赖于低层次的模块，它们都应该依赖于抽象。

在传统软件设计中，我们一般都是上层代码依赖下层代码，当下层代码变动时，我们上层代码要跟着变动，维护成本比较高。这时我们可以上层定义接口，下层来实现这个接口，从而使得下层依赖于上层，降低耦合度。（PC主板和鼠标键盘接口就是一个很好的例子，各数据厂商根据主板上的接口来生产自己的鼠标键盘产品，这样鼠标坏了后我们可以随便换个符合接口要求的鼠标，而不用修改主板上的什么东西）

#### 控制反转

上面讲的依赖倒置是一种原则，而控制反转就是实现依赖倒置的一种具体方法。控制反转核心是把上层（类）所依赖单元的实例化过程交由第三方实现，而类中不允许存在对所依赖单元的实例化语句。举个例子：

```php

class Comment
{
	...

	public function afterInsert()
	{
		$notification = new EmailNotification(...);
		$notification->send(...);
	}
}

```

如上，假如我们在用户提交评论后通知被评论者，这里通知方式是邮件，而且是直接在类中实例化邮件通知类，这样代码耦合度高，如果换个短信通知方式就不得不改这里面代码，具体好的实现我们下面会讲到。

#### 依赖注入

依赖注入是一种设计模式，是一种IoC的具体实现，实现了IoC自然就符合依赖倒置原则。依赖注入的核心思想是把类中所依赖单元的实例化过程放到类外面中去实现，然后把依赖注入进来。常用的依赖注入方式有属性注入和构造函数注入。比如用构造函数注入解耦上面代码：

```php

// 通知接口
interface Notifaction
{
	public function send(...);
}


// 短信通知实现通知接口
class SmsNotification implements Notification
{
	public function send(...)
	{
		...
	}
}

// 评论类
class Comment
{
	...

	protected $notification;

	public function __construct(Notification $smsNotification)
	{
		$this->notification = $smsNotification;
	}

	public function afterInsert()
	{
		$this->notification->send(...);
	}
}

// 实例化短信通知类
$smsNotification = new SmsNotification(...);

// 通过构造函数方法注入
$comment = new Comment($smsNotification);

...

$comment->save();

```

这样，我们先定义Notification接口，里面有个send方法，让后面的通知者不管是邮件类还是短信类都实现这个接口，然后在外面通过构造函数方式注入进来，这样就解决了Comment类对具体通知方法的依赖，只要是实现了Notification接口的，都可以通过构造函数传进来，Comment类完全不用做任何修改。这样无论对于代码维护还是单元测试（可以模拟实现一个Notification类），都非常方便。

依赖注入是IoC的一种具体实现，是一种解耦手段。当然IoC不止这一种实现，比如Yii中的Service Locator（服务定位器）

## IoC container/DI container

当项目比较大时，就会有许多类似上面评论类和通知类这种依赖关系，整个项目会非常复杂。这时候就需要一个集中的地方来管理这些依赖，我们把它叫IoC container 控制反转容器，它提供了动态地创建、注入依赖单元、映射依赖关系等功能。这样可以集中管理依赖关系，也减少很多代码量。

## Service container 服务容器

Laravel官方文档这样定义服务容器：Laravel服务容器是用于管理类的依赖和执行依赖注入的工具。

首先，服务容器通过DI依赖注入方式实现了IoC，然后它还支持另一种实现：绑定与解析。

#### 绑定

几乎所有服务容器绑定操作都是Service provider(服务提供器)中注册绑定的，服务提供器中可以通过$this->app方式获取服务容器，然后通过服务容器提供的方法比如$this->app->bind(...)等进行具体服务绑定。类似支持的绑定方式还有：

* 简单绑定
* 绑定单例
* 绑定实例
* 绑定初始数据
* 绑定接口到实现
* 上下文绑定
* 标记
* 扩展绑定

具体可以查看官方文档：https://laravel.com/docs/5.6/container


#### 解析

绑定后可以从服务容器中解析出对象才能够使用。解析方法包括：

* 通过 make 方法，接收一个你想要解析的类或者接口
* 通过数组方式从容器中解析对象
* 自动注入

##### 示例

我们先定义一个自己的类

```php

class Foo
{
	public function bar()
	{
		...
	}
}

```

我们把Foo类简单绑定到服务容器：

```php

App::bind("foo", function($app){
	return new Foo();
})

```

平时在上下文获取这个实例：	

```php

$foo = App::make("foo");    // $foo就是Foo类的实例

```
当然，这种绑定和解析平时我们在代码中随便可以写到哪里，但是多了的话就乱起来了。所以我开头说几乎所有这种依赖服务绑定操作都是在Service provider中进行的。

下面就给大家介绍Service provider。

## Service provider 服务提供器

为了让依赖注入的代码不至于混乱，Laravel提供了一个服务提供器（Service Provider），它将这些依赖聚集在了一块，统一申明和管理，让依赖变得更加容易维护。

下面都是一些抄来的官话、套话（-_-'），大家可以直接跳到代码示例，后续再查看官方文档加深理解。

所有服务提供者都需要继承Illuminate\Support\ServiceProvider类。大多数服务提供者都包含 register 和 boot 方法。register方法中，只能将事务绑定到服务容器。不应该在register方法中尝试注册任何事件监听器，路由或者任何其他功能。可以为服务提供者的boot方法设置类型提示。服务容器会自动注入需要的任何依赖。boot方法将在所有其他服务提供者均已注册之后调用。

所有服务提供者都在 config/app.php 配置文件中注册。可以选择推迟服务提供者的注册，直到真正需要注册绑定时，这样可以提供应用程序的性能。

##### 示例

上一个示例我们是自己在上下文中随意定义、获取。下面我们以服务提供者的方式进行：

```php

use Illuminate\Support\ServiceProvider;

class FooServiceProvider extends ServiceProvider {

    public function register()
    {
        $this->app->bind('foo', function()
        {
            return new Foo();
        });
    }

}

```

上面实现了一个Foo的服务提供，我们可以手动注入到上下文中：

```php

App::register('FooServiceProvider');

```

当然我们更多的是通过配置文件来完成的，在app/config/app.php中的providers数组里面增加一行：

```php

'providers' => [
    …
       ‘FooServiceProvider’,
],

```

这样我们可以在上下文中直接获取实例：

```php

App::make(‘foo’)

```

当然，我们还可以通过门面方式，更方便的操作Foo类。


## Facades 门面

门面实际上是应用了设计模式中的外观模式：

外观模式（Facade），他隐藏了系统的复杂性，并向客户端提供了一个可以访问系统的接口。这种类型的设计模式属于结构性模式。为子系统中的一组接口提供了一个统一的访问接口，这个接口使得子系统更容易被访问或者使用。 

Laravel中随处可见这些静态方法的调用：

```php

$value = Cache::get('key');

```

这些静态调用实际上调用的并不是静态方法，而是通过PHP的魔术方法 __callStatic() 将请求转到了相应的方法上。

比如如果我们看一下 Illuminate\Support\Facades\Cache 这个类，你会发现类中根本没有 get 这个静态方法：

```

class Cache extends Facade
{
    /**
     * 获取组件的注册名称。
     *
     * @return string
     */
    protected static function getFacadeAccessor() { return 'cache'; }
}

```

这其中的奥秘在基类Facade中：

```php

public static function __callStatic($method, $args)
{
	// 获取实例
    $instance = static::getFacadeRoot();

    if (!$instance) {
        throw new RuntimeException('A facade root has not been set.');
    }

    // 真正调取对应的方法
    return $instance->$method(...$args);
}

```

这里面有一个获取实例的过程，然后去调用具体方法。

#### 示例

接上一个示例，我们平常是通过App::make('foo')来获取实例，然后再调用具体方法。现在我们通过门面的方式简化这个流程：

先定义一个门面：

```php

use Illuminate\Support\Facades\Facade;

class Foo extends Facade {

    protected static function getFacadeAccessor() { return ‘foo’; }

}

```

然后我们可以很方便的使用Foo类某个方法：

```php

Foo::bar();

```

## Contracts 契约

Laravel的契约是一组定义框架提供的核心服务的接口。后续针对这个接口可以有多种实现，解耦了具体实现的依赖，在不改变代码逻辑的情况下获得更加多态的结果。

比如你只需在配置文件中指明你需要的缓存驱动（redis，memcached，file等），Laravel会自动帮你切换到这种驱动，而不需要你针对某种驱动更改逻辑和代码。

## 总结

这些都是些基础的抽象概念，但是是非常重要的，Laravel中随处可见这些思想，是一切实现的基石。

学习的过程中基础是非常重要的，知其然必知其所以然。就像道与术，道是在术之前的，老子说过：”有道无术，术尚可求也，有术无道，止于术“。不过实际中应该是相辅相成的关系，“以道统术，以术得道”。

## 引用

https://laravel.com/docs/5.6/container
https://laravel-china.org/docs/laravel/5.6
http://www.digpage.com/di.html
http://yansu.org/2014/12/06/ioc-and-facade-in-laravel.html
