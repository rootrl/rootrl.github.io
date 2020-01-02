---
title: Android Bug记："Canvas: trying to use a recycled bitmap android.graphics.Bitmap"
date: 2020-01-02 22:18:56
tags:
- Android
categories:
- 开发语言
- Android
---

### Bug日志

最近一个项目中遇到一个诡异Bug，详细日志如下：

```bash
E/MainActivity: executeTextView: test for get drawable:  last source: android.graphics.drawable.BitmapDrawable@8c352b2
    executeTextView: test for get drawable: isVisible true alpha:  255 last source: android.graphics.drawable.BitmapDrawable@8c352b2
W/Bitmap: Called hasAlpha() on a recycle()'d bitmap! This is undefined behavior!
    Called hasAlpha() on a recycle()'d bitmap! This is undefined behavior!
    Called hasAlpha() on a recycle()'d bitmap! This is undefined behavior!
W/Bitmap: Called hasAlpha() on a recycle()'d bitmap! This is undefined behavior!
E/MainActivity: Glide结束
    executeImageView: ...
E/MainActivity: showQrCode: 举报二维码1:
    showQrCode: 举报二维码2: https://xxx.com/upload/equipmentWxQRCode/15776698271ada7952f9ead4d5.jpg
D/AndroidRuntime: Shutting down VM
E/AndroidRuntime: FATAL EXCEPTION: main
    Process: com.rootrl.adviewer, PID: 29128
    java.lang.RuntimeException: Canvas: trying to use a recycled bitmap android.graphics.Bitmap@ac257b9
        at android.graphics.Canvas.throwIfCannotDraw(Canvas.java:1271)
        at android.view.DisplayListCanvas.throwIfCannotDraw(DisplayListCanvas.java:257)
        at android.graphics.Canvas.drawBitmap(Canvas.java:1415)
        at android.graphics.drawable.BitmapDrawable.draw(BitmapDrawable.java:528)
        at android.widget.ImageView.onDraw(ImageView.java:1298)
        at android.view.View.draw(View.java:17201)
        at android.view.View.updateDisplayListIfDirty(View.java:16183)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at androidx.constraintlayout.widget.ConstraintLayout.dispatchDraw(ConstraintLayout.java:2023)
        at android.view.View.updateDisplayListIfDirty(View.java:16178)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at androidx.constraintlayout.widget.ConstraintLayout.dispatchDraw(ConstraintLayout.java:2023)
        at android.view.View.draw(View.java:17204)
        at android.view.View.updateDisplayListIfDirty(View.java:16183)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at android.view.View.updateDisplayListIfDirty(View.java:16178)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at android.view.View.updateDisplayListIfDirty(View.java:16178)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at android.view.View.updateDisplayListIfDirty(View.java:16178)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at android.view.View.updateDisplayListIfDirty(View.java:16178)
        at android.view.View.draw(View.java:16967)
        at android.view.ViewGroup.drawChild(ViewGroup.java:3727)
        at android.view.ViewGroup.dispatchDraw(ViewGroup.java:3513)
        at android.view.View.draw(View.java:17204)
        at com.android.internal.policy.DecorView.draw(DecorView.java:754)
        at android.view.View.updateDisplayListIfDirty(View.java:16183)
        at android.view.ThreadedRenderer.updateViewTreeDisplayList(ThreadedRenderer.java:648)
        at android.view.ThreadedRenderer.updateRootDisplayList(ThreadedRenderer.java:654)
        at android.view.ThreadedRenderer.draw(ThreadedRenderer.java:762)
        at android.view.ViewRootImpl.draw(ViewRootImpl.java:2800)
        at android.view.ViewRootImpl.performDraw(ViewRootImpl.java:2608)
        at android.view.ViewRootImpl.performTraversals(ViewRootImpl.java:2215)
        at android.view.ViewRootImpl.doTraversal(ViewRootImpl.java:1254)
        at android.view.ViewRootImpl$TraversalRunnable.run(ViewRootImpl.java:6338)
        at android.view.Choreographer$CallbackRecord.run(Choreographer.java:874)
        at android.view.Choreographer.doCallbacks(Choreographer.java:686)
        at android.view.Choreographer.doFrame(Choreographer.java:621)
        at android.view.Choreographer$FrameDisplayEventReceiver.run(Choreographer.java:860)
        at android.os.Handler.handleCallback(Handler.java:755)
        at android.os.Handler.dispatchMessage(Handler.java:95)
        at android.os.Looper.loop(Looper.java:154)
        at android.app.ActivityThread.main(ActivityThread.java:6121)
        at java.lang.reflect.Method.invoke(Native Method)
        at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:905)
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:795)
I/Process: Sending signal. PID: 29128 SIG: 9
Process 29128 terminated.
```

### Bug初步分析

其实字面上看上去很简单。但是诡异在发生场景：

- 只在安卓横屏模式下发生，竖屏模式下正常。

- 有一张特定图片才会出现问题，其他图片均不会。而这个图片无论分辨率大小还是文件大小均不大，其他比它大十几倍的都正常运行。

报错原因从日志上看到很简单：使用了一个已经被回收的bitmap资源（我这里使用的是Glide图片处理库）。但是结合我的使用场景和发生场景（只在横屏下），再加上Glide对于我来说是一个黑箱。 种种原因结合看来是一个难调的bug。

后来发现发生的地方是imageView的Placeholder设置阶段。代码如下：
    
```java
if (currentView == AdConstant.VIEW_TYPE_TEXT_VIEW) {
    if (adImageView.getDrawable() != null) {
        requestOptions.placeholder(adImageView.getDrawable());
    }
}
```

设置这个Placeholder是为了解决图片切换时的闪黑屏问题，一是去掉Glide的Animate，二是设置这个Placeholder，把当前Image View的Drawable作为默认图片。而由于我的业务逻辑复杂，有图片和视频的轮播，有可能在设置时找不到这个Drawable的Bitmap资源，好吧，说有可能是因为我也不能给个具体的原因-_-''，因为结合我上面提到的两个特定发生场景，实在是太诡异了。

### Bug深入分析

后来我看到github上官方bumptech/glide也有一大堆issues，有人说是glide版本问题，但是我更新到最新的4.10.0依旧无解。

最后看到官方的Common errors文档，http://bumptech.github.io/glide/doc/resourcereuse.html#common-errors

```java
Glide’s BitmapPool has a fixed size. When Bitmaps are evicted from the pool without being re-used, Glide will call recycle(). If an application inadvertently continues to hold on to the Bitmap even after indicating to Glide that it is safe to recycle it, the application may then attempt to draw the Bitmap, resulting in a crash in onDraw().

This problem could be due to the fact that one target is being used for two ImageViews, and one of the ImageViews still tries to access the recycled Bitmap after it has been put into the BitmapPool. This recycling error can be hard to reproduce, due to several factors: 1) when the bitmap is put into the pool, 2) when the bitmap is recycled, and 3) what the size of the BitmapPool and memory cache are that leads to the recycling of the Bitmap. The following snippet can be put into your GlideModule to help making this problem easier to reproduce:

@Override
public void applyOptions(Context context, GlideBuilder builder) {
    int bitmapPoolSizeBytes = 1024 * 1024 * 0; // 0mb
    int memoryCacheSizeBytes = 1024 * 1024 * 0; // 0mb
    builder.setMemoryCache(new LruResourceCache(memoryCacheSizeBytes));
    builder.setBitmapPool(new LruBitmapPool(bitmapPoolSizeBytes));
}
The above code makes sure that there is no memory caching and the size of the BitmapPool is zero; so Bitmap, if happened to be not used, will be recycled right away. The problem will surface much quicker for debugging purposes.
```

第一段说明了真正原因，Bitmap在BitmapPool中被剔除而没有被重用时，Glide会调用recycle()，但是如果Application在被告知安全回收了Bitmap之后还是保留这个Bitmap，继而绘制Bitmap时，在onDraw中就会崩溃。

我这个Placeholder就发生在这种情况下。


### Bug解决

我这边解决思路是重新设置BitmapPool的大小，这需要重写AppGlideModule，代码如下：

```
package com.rootrl.adviewer.glide;

import android.content.Context;

import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.annotation.GlideModule;
import com.bumptech.glide.load.engine.bitmap_recycle.LruBitmapPool;
import com.bumptech.glide.load.engine.cache.LruResourceCache;
import com.bumptech.glide.module.AppGlideModule;

@GlideModule
public class AdImageGlideModule extends AppGlideModule {
    @Override
    public void applyOptions(Context context, GlideBuilder builder) {
        int bitmapPoolSizeBytes = 1024 * 1024 * 200; // 200mb
        int memoryCacheSizeBytes = 1024 * 1024 * 200; // 200mb
        builder.setMemoryCache(new LruResourceCache(memoryCacheSizeBytes));
        builder.setBitmapPool(new LruBitmapPool(bitmapPoolSizeBytes));
    }
}
```

这里有几点要注意，不然项目中没有GlideApp对象。

- 类中添加@GlideModule注解
- 如同package com.rootrl.adviewer.glide，这个Module放在项目路径的glide package目录（需新建）
- 改下build.grdle配置

其中第三条具体如下，注意除了glide依赖，还需annotationProcessor项：
```bash
implementation 'com.github.bumptech.glide:glide:4.10.0'
annotationProcessor 'com.github.bumptech.glide:compiler:4.10.0'
```

然后，点AS的Build => Make Project，之后就可以在项目中使用集成自己GlideModule的GlideAPP了。

使用方式也是用GlideAPP替换原来的Glide就可以。

```
// 替换前
Glide.with(MainActivity.this).listener(...).load(uri).apply(requestOptions).into(adImageView);

// 替换后
GlideApp.with(MainActivity.this).listener(...).load(uri).apply(requestOptions).into(adImageView);

```

### 总结

其实这里还没有具体深入，因为安卓对我来说还是一个实用为主阶段。最后强调是图片处理库非常推荐Glide，它的缓存机制很实用。然后视频的缓存推荐danikula:videocache库。
