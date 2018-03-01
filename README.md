# react-native-zhugeio
诸葛移动统计的react-native插件

### 1. 环境需求
* iOS 8.0

   部分代码运行于8.0的系统
* Android SDK 11+

   zhuge SDK本身代码支持Android 11+的系统，但React-native仅运行于Android 16+

* react-native 0.50+
* react-native-cli 2.0+

   项目本身基于以上版本的react-native开发。因此目前不确定是否支持低版本的react-native。若集成不成功，请联系[Zhuge](https://zhugeio.com/)。
* pod 1.0+
  
  iOS系统的集成依赖于cocoaPod工具

### 2. 集成方法

在你的React-native项目目录下

  ```
    $ npm install  react-native-plugin-zhugeio --save

    $ react-native link

  ```

#### 2.1 iOS

* 若在你的react-native项目的ios文件夹下，没有Podfile文件，那么初始化Pod

    ```
    $ pod init

    ```
以上命令将在ios目录下创建Podfile文件。

* 编辑Podfile文件

    ```
    platform :ios, '8.0'

    target 'yourApp' do
        pod 'yoga', :path => '../node_modules/react-native/ReactCommon/yoga'
        pod 'React', path: '../node_modules/react-native',:subspecs => ['DevSupport']
        pod 'react-native-plugin-zhugeio', path: '../node_modules/react-native-plugin-zhugeio'
    end

    ```

* 执行```pod install```
* 在```ios/youProjectName/AppDelegate.m```文件中，找到```application didFinishLaunchingWithOptions ```方法，在其中加入如下代码

```
    #import <Zhugeio/Zhuge.h>

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [[Zhuge sharedInstance] startWithAppKey:@"Your App Key" launchOptions:launchOptions];
    }
```
* 若是私有部署的用户，需要更改数据上传地址，那么请将上述代码更改为：

```
    #import <Zhugeio/Zhuge.h>

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        //设置上传地址，一般用户无需更改
        [[Zhuge sharedInstance] setUploadURL:@"https://www.zhugeio.com" andBackupUrl:nil];
        [[Zhuge sharedInstance] startWithAppKey:@"Your App Key" launchOptions:launchOptions];
    }
```

#### 2.2 Android


* 检查```android/setting.gradle```配置有没有包含以下内容：

  ```
     include ':react-native-plugin-zhugeio'
     project(':react-native-plugin-zhugeio').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-plugin-zhugeio/android')

  ```

* 检查```android/app/build.gradle```dependencies是否包含如下内容

  ```
    compile project(':react-native-plugin-zhugeio')

  ```

* 找到 ```android/youApp/src/main/java.../MainApplication.java``` 文件，添加如下代码

  ```
    import com.zhuge.analysis.stat.ZhugeSDK;// <--导入SDK
    import com.zhuge.reactnativezhuge.RNZhugeioPackage;//<--导入react-native接口

    public class MainApplication extends Application implements ReactApplication {
        @Override
        public void onCreate(){
           Super.onCreate();
           ...
           //ZhugeSDK初始化
           ZhugeSDK.getInstance().init(this,"yourAppKey","youAppChannel");   
           ...
   
        }

        private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {

          @Override
          protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
               new MainReactPackage(),
               //注册Zhugeio
               new RNZhugeioPackage()
            );
          }
        };
    }

    ```
* 若您是私有部署的用户，需要更改数据上传地址，那么请将上述```onCreate()```里的代码更改为：

    ```
        @Override
        public void onCreate(){
           Super.onCreate();
           ...
           //设置上传地址，普通用户请勿更改。必须在调用init之前设置
           ZhugeSDK.getInstance().setUploadURL("https://www.zhugeio.com",null)
           //ZhugeSDK初始化
           ZhugeSDK.getInstance().init(this,"yourAppKey","youAppChannel");   
           ...
   
        }

    ```

### 3. 使用说明

* 导入Zhugeio

   ```
   import Zhugeio from 'react-native-plugin-zhugeio'

   ```

* track 追踪事件

	```
	Zhugeio.track('事件名称',{'属性1':'值1','属性2':'值2'});
	
	```
* 自定义时长事件 

    使用```startTrack()```开始事件

    ```
    Zhugeio.startTrack('事件名称');
 
    ```

    使用相同的事件名称结束事件

    ```
    Zhugeio.endTrack('事件名称'，{'属性1':'值1'});

    ```
    
    ```startTrack()```与```endTrack()```需成对出现，单独使用没有效果。
    
* 标记用户

    使用```identify()```标记用户
    
    ```
    Zhugeio.identify('用户ID',{'用户属性':'用户值'})
    
    ```

* 开启实时调试

    ```
    Zhugeio.openDebug();

    ```
    
* 开始日志输出
   
    该方法仅对Android平台可用，iOS平台请参阅 [iOS集成文档](http://docs.zhugeio.com/dev/iOS.html)

    ```
    Zhugeio.openLog();
    
    ```
