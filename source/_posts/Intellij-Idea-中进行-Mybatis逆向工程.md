---
title: Intellij Idea 中进行 Mybatis逆向工程
date: 2019-05-21 20:45:49
tags:
 - mybatis
categories:
 - 开发语言
 - Java
---

### 开篇

Mybatis有个实用的功能就是逆向工程，能根据表结构反向生成实体类，这样能避免手工生成出错。市面上的教程大多都很老了，大部分都是针对mysql5的，以下为我执行mysql8时的经验。

### 引入工程

这里使用的是maven包管理工具，在pom.xml添加以下配置，以引入mybatis.generator

```xml
<build>
    <finalName>SpringMVCBasic</finalName>
    <!-- 添加mybatis-generator-maven-plugin插件 -->
    <plugins>
      <plugin>
        <groupId>org.mybatis.generator</groupId>
        <artifactId>mybatis-generator-maven-plugin</artifactId>
        <version>1.3.2</version>
        <configuration>
          <verbose>true</verbose>
          <overwrite>true</overwrite>
        </configuration>
      </plugin>
    </plugins>
  </build>
```
### 配置文件

在maven项目下的src/main/resources 目录下新建generatorConfig.xml和generator.properties文件

generator.properties

```xml
jdbc.driverLocation=F:\\maven-repository\\mysql\\mysql-connector-java\\8.0.16\\mysql-connector-java-8.0.16.jar
jdbc.driverClass=com.mysql.cj.jdbc.Driver
jdbc.connectionURL=jdbc:mysql://localhost:3306/demo?useUnicode=true&characterEncoding=utf-8
jdbc.userId=test
jdbc.password=test123
```
注意：
1，generator.properties里面的jdbc.driverLocation指向是你本地maven库对应mysql-connector地址
2，与老版本不同，这里driversClass为com.mysql.cj.jdbc.Driver

generatorConfig.xml

```xml

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>

    <!--导入属性配置-->
    <properties resource="generator.properties"></properties>

    <!--指定特定数据库的jdbc驱动jar包的位置(绝对路径)-->
    <classPathEntry location="${jdbc.driverLocation}"/>

    <context id="default" targetRuntime="MyBatis3">

        <!-- optional，旨在创建class时，对注释进行控制 -->
        <commentGenerator>
            <!--是否去掉自动生成的注释 true:是-->
            <property name="suppressDate" value="true"/>
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>

        <!--jdbc的数据库连接：驱动类、链接地址、用户名、密码-->
        <jdbcConnection
                driverClass="${jdbc.driverClass}"
                connectionURL="${jdbc.connectionURL}"
                userId="${jdbc.userId}"
                password="${jdbc.password}">
        </jdbcConnection>

        <!-- 非必需，类型处理器，在数据库类型和java类型之间的转换控制-->
        <javaTypeResolver>
            <property name="forceBigDecimals" value="false"/>
        </javaTypeResolver>

        <!-- Model模型生成器,用来生成含有主键key的类，记录类 以及查询Example类
            targetPackage     指定生成的model生成所在的包名
            targetProject     指定在该项目下所在的路径
        -->
        <javaModelGenerator targetPackage="com.ifly.outsourcing.entity"
                            targetProject="src/main/java">
            <property name="enableSubPackages" value="true"/>
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>


        <!--Mapper映射文件生成所在的目录 为每一个数据库的表生成对应的SqlMap文件 -->
        <sqlMapGenerator targetPackage="mappers"
                         targetProject="src/main/resources">
            <property name="enableSubPackages" value="false"/>
        </sqlMapGenerator>

        <!-- 客户端代码，生成易于使用的针对Model对象和XML配置文件 的代码
                type="ANNOTATEDMAPPER",生成Java Model 和基于注解的Mapper对象
                type="MIXEDMAPPER",生成基于注解的Java Model 和相应的Mapper对象
                type="XMLMAPPER",生成SQLMap XML文件和独立的Mapper接口
        -->

        <javaClientGenerator type="XMLMAPPER" targetPackage="com.ifly.outsourcing.dao"
                             targetProject="src/main/java">
            <property name="enableSubPackages" value="true"/>
        </javaClientGenerator>

        <!-- 数据表进行生成操作 tableName:表名; domainObjectName:对应的DO -->
        <table tableName="user" domainObjectName="user"
               enableCountByExample="false" enableUpdateByExample="false"
               enableDeleteByExample="false" enableSelectByExample="false"
               selectByExampleQueryId="false">
        </table>

    </context>
</generatorConfiguration>

```

注意：这里主要注意修改对应的javaModelGenerator ，sqlMapGenerator，javaClientGenerator 为自己的生成路径。以及添加自己的数据表。

### 在Intellij IDEA添加一个“Run运行”选项

点击菜单栏的run，新建一个选项为maven的configurations，name为自己方便看，比如generator，commnd line注意写为：

```bash
mybatis-generator:generate -e
```

点击run即可生成对应文件。
