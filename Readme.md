GodotYodo1Mas
=====
This is an iOs Yodo1Mas plugin for Godot Engine (https://github.com/okamstudio/godot) 3.2.3 or higher. 


When you integrate the SDK, you import the SDK library file into your project so you can use that file’s functions. Integrating the MAS SDK into your mobile app project gives you access to MAS's fully managed monetization solution. This solution taps into multiple add mediation platforms, selecting the one best suited for your game and monetizing through high quality ad networks that serve in-app ads.

Before you can start monetizing your app, you’ll need to integrate the MAS SDK.

Integrating the SDK
----------

First of all, you need download this repository. It consists of 3 folders:
- _yodo1mas-plugin-android_. Android plugin.
- _yodo1mas-plugin-ios_. iOs plugin.
- _demo_. Godot project, will work on iOs and android platforms.


### iOS
1. Clone this repository.
2. Clone godot repository.
3. Go to godot repository folder then open _modules_ folder.
<img src="/images/go_to_modules.png" width="500">

4. Create _yodo1mas_ folder. It will contain MAS plugin sources.
<img src="/images/create_yodo1mas.png" width="500">

5. Copy all content from _yodo1mas-plugin-ios_ folder to  _yodo1mas_ folder.
<img src="/images/ios_plugin_copy.png" width="500">

Now we need to compile a library for our future Xcode project.
[Here](https://docs.godotengine.org/en/stable/development/compiling/compiling_for_ios.html) is an official documentation about plugin compilation in godot.
1. Open **Terminal** program on your Mac.
2. Navigate to godot repository folder. For example, if you clone godot repository godot-3.2.3-stable in Downloads folder then use this commands:
  - **cd**. This command navigates you to your home folder.
  - **cd Downloads/godot-3.2.3-stable**. Navigates to godot folder.
  - **ls**. Display all files in godot folder.
<img src="/images/terminal_navigates_to_godot.png" width="500">

3. Compile the engine for iOs platform. 
You need a program **scons** to be installed. The easiest way you do it through Homebrew. 
Homebrew installation is [here](https://brew.sh).
cscons installation via homebrew is [here](https://formulae.brew.sh/formula/scons). 
After that type commands in the terminal:

```
scons p=iphone tools=no target=release arch=arm
scons p=iphone tools=no target=release arch=arm64
lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a -output bin/libgodot.iphone.release.fat.a
```

You can compile only for arm or arm64 version. Just use one command. 
Compiled ios library will end up in bin folder.
<img src="/images/compiled_ios_lib.png" width="500">


----------
For iOs platform you need only script yodo1mas.gd from our demo project. It is wrapper for all MAS functions.
Below we provide an example how to compile demo project on iOs. You will be able to compile your poject in the same way.

1. Export the project for iOs platform. Xcode project will be created.
<img src="/images/export_ios.png" width="500">

2. Here is a directory with Xcode project. For now GodotYodo1Mas.a file is a library of godot engine but without Yodo1 MAS SDK. 
You already compiled a required library before.
<img src="/images/godot_ios_libraries.png" width="500">

Rename file _libgodot.iphone.opt.arm64.a_ to _GodotYodo1Mas.a_ and copy-paste it to Godot Xcode project.

Now library  _GodotYodo1Mas.a_ in Xcode project contains MAS SDK wrapper.

3. Use cocoapods to add all MAS SDKs in your Xcode project. Create Podfile in Xcode project via terminal command **touch Podfile**. 
Do not forget to navigate into Xcode folder with command _cd_ .
4. Open the project's Podfile file and add the following code to the target of the application:
```
source 'https://github.com/Yodo1Games/MAS-Spec.git'
source 'https://github.com/Yodo1Games/Yodo1Spec.git'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

project 'GodotYodo1Mas.xcodeproj'

target 'GodotYodo1Mas' do
   pod 'FBSDKCoreKit'
   pod 'Yodo1MasStandard', '~> 4.0.1.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

```
You can specify project name, platform and many other options in this file. Take a look at [cocoapods documentation](https://guides.cocoapods.org) for details.

5. Execute the following command in Terminal: **pod install --repo-update**. This command will download all required Yodo1 MAS libraries and create xCode workspace file.
<img src="/images/cocoapods_install.png" width="500">
Xcode project structure after pods installation.
<img src="/images/xcode_files.png" width="500">

Now we need to set up Xcode project. 
1. Open **GodotYodo1Mas.xcworkspace** file.
2. Open **GodotYodo1Mas-Info.plist** file in text editor.
<img src="/images/open_info_plist.png" width="500">

3.Add AppLovin SDK Key:

```
<key>AppLovinSdkKey</key>
<string>xcGD2fy-GdmiZQapx_kUSy5SMKyLoXBk8RyB5u9MVv34KetGdbl4XrXvAUFy0Qg9scKyVTI0NM4i_yzdXih4XE</string>
```

4. Add App Transport Security. Apple has added in controls for ATS in iOS9. To ensure uninterrupted ad delivery across all Mediation Networks.

```
<key>NSAppTransportSecurity</key> 
<dict> 
    <key>NSAllowsArbitraryLoads</key> 
    <true/> 
</dict>
```

5. Add AppTrackingTransparency. 
iOS 14 requires publishers to obtain permission to track user devices across applications.

```
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

6. Add AdMob App ID

```
<key>NSUserTrackingUsageDescription</key>
<string>!!!Your MAS AdMob App ID!!!</string>
```

7. Advertising Network ID
Games for users running iOS 14 or later need to include the network ID of each advertising platform in the attribute list file

```
    <key>SKAdNetworkItems</key>
    <array>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2u9pt9hc89.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4468km3ulz.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4fzdc2evr5.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>7ug5zh24hu.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>8s468mfl3y.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>9rd848q2bz.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>9t245vhmpl.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>av6w8kgt66.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>f38h382jlk.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>hs6bdukanm.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>kbd757ywx3.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ludvb6z3bs.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>m8dbw4sv7c.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>mlmmfzh3r3.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>prcb7njmu6.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>t38b2kh725.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>tl55sbb4fm.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>wzmmz9fp6w.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>yclnxrl5pm.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ydx93a7ass.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>n38lu8286q.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v9wttpbfk9.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3sh42y64q3.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>44jx6755aq.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4pfyvq9l8r.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>5l3tpt7t6e.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>5lm9lj6jb7.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>7rz58n8ntl.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>c6k4g5qg8m.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cg4yq2srnc.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>f73kdq92p3.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ggvn48r87g.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>klf5c3l5u5.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>p78axxw29g.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ppxm28t8ap.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>uw77j35x4d.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v72qych5uu.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>w9q455wk68.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>wg4vff78zm.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>su67r6k2v3.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>578prtvx9j.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ecpz2srf59.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>22mmun2rn5.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>238da6jt44.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3rd42ekr43.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>424m5254lk.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>44n7hlldy6.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>488r3q3dtq.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4dzt52r2t5.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>5a6flpkh64.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>bvpn9ufa9b.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>glqzh8vgby.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>lr83yxwka7.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v79kvwwj4g.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>zmvfpc5aq8.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>gta9lk7p23.skadnetwork</string>
      </dict>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>n9x2a789qt.skadnetwork</string>
      </dict>
    </array>
```

Save and close **GodotYodo1Mas-Info.plist** file.

8. Set up build excluded architectures. For example, you can exclude armv7 if you did not compile for it. Also, set iOs deployement target to 10.0. 
<img src="/images/xcode_architectures.png" width="500">

7. Create empty swift file. In menu: File -> New -> File -> Choose Swift File -> Next -> Create.
In the popup 'Would you like to configure an Objective-C bridging header?' choose **Create Bridging Header**
<img src="/images/create_bridging_header.png" width="500">

8. You can compile a build :)


#### !!IMPORTANT!!
After you prepare Xcode project in Godot editor use option **Export PCK/ZIP** and replace pck file.
<img src="/images/godot_pck.png" width="500">

### Android

## Setup new project

1. Configure, install  and enable the "Android Custom Template" for your project, just follow the [official documentation](https://docs.godotengine.org/en/stable/getting_started/workflow/export/android_custom_build.html);
2. Copy two files ```GodotYodo1Mas.gdap``` and ```GodotYodo1Mas.***.aar``` from demo/android/plugins to your Godot project. You have to put them in the path ```res://android/plugins```.
3. Put file ```demo/scripts/yodo1mas.gd``` into your Godot project.
4. On the Project -> Export... -> Android -> Options -> 
    - Permissions: check the permissions for _Access Network State_ and _Internet_
    - Custom Template: check the _Use Custom Build_
    - Plugins: check the _Godot Yodo1 Mas_ (this plugin)
5. Add AdMob App ID
    - Add your AdMob App ID to your app's ```res//android/build/AndroidManifest.xml``` file by adding the <meta-data> tag. 
    - You can find your App ID in the MAS dashboard.
    - Please replace android:value with your own AdMob App ID

```
<manifest>
	<application>
	<!-- Sample AdMob App ID: ca-app-pub-3940256099942544~3347511713 -->
	<meta-data
		android:name="com.google.android.gms.ads.APPLICATION_ID"
		android:value="YOUR_ADMOB_APP_ID"/>
	</application>
</manifest>
```

6. Change android label with attribute **tools:replace**. Example:

```
 <application tools:replace="android:label" android:label="GodotYodo1Mas"
```

7. Edit **build.gradle** file. You need to add repositories and activate multiDexEnabled.

```
maven { url "https://dl.bintray.com/ironsource-mobile/android-sdk" }
maven { url "https://dl.bintray.com/ironsource-mobile/android-adapters" }
maven { url "https://dl.bintray.com/yodo1/MAS-Android" }
maven { url "https://dl.bintray.com/yodo1/android-sdk" }
```

```
	multiDexEnabled true
```

Take a look at build.gradle file in the demo project.

8. You can export Android project. Apk will be created.


**NOTE**: everytime you install a new version of the Android Build Template this step must be done again, as the ```AndroidManifest.xml``` file will be overriden.


## Compiling the Plugin (optional)
If you want to compile the plugin by yourself, it's very easy:
1. clone this repository;
2. checkout the desired version;
3. download the AAR library for Android plugin from the official Godot website;
4. copy the downloaded AAR file into the `yodo1mas-plugin-android/godot-lib.release/` directory and rename it to `godot-lib.release.aar`;
5. using command line go to the `yodo1mas-plugin-android/` directory;
6. run `gradlew build`.

Also you can make build from android studio.

If everything goes fine, you'll find the `.aar` files at `yodo1mas-plugin-android/godotadmob/build/outputs/aar/`.


Godot manual
----------

### Banner integration
1. Set up the banner signals
<img src="/images/banner_signals.png" width="500">

2. Check the loading status of banners

```
var banner_loaded = yodo1mas.is_banner_ad_loaded()
```

3. Show banner ad

Use the show method to display a banner:
```
yodo1mas.show_banner_ad()
```

The method uses default aligment parameters BANNER_TOP | BANNER_HORIZONTAL_CENTER and a default offset of (X: 0,Y: 0):
```
yodo1mas.show_banner_ad_with_align(yodo1mas.BannerAlign.BANNER_RIGT | yodo1mas.BannerAlign.BANNER_BOTTOM)
```

You can  customize the banner alignment and offset.
```
yodo1mas.show_banner_ad_with_align_and_offset(yodo1mas.BannerAlign.BANNER_RIGT | yodo1mas.BannerAlign.BANNER_BOTTOM, Vector2(10,10))
```


4. Dismiss banner ad

```
yodo1mas.dismiss_banner_ad()
```

### Interstitial integration
1. Set up the interstitial signals
<img src="/images/interstitial_signals.png" width="500">

2. Check the loading status of interstitials

```
var is_interstitial_loaded = yodo1mas.is_interstitial_ad_loaded()
```

3. Show interstitial ad
```
yodo1mas.show_interstitial_ad()
```

### Rewarded ad integration
1. Set up the rewarded video signals
<img src="/images/video_signals.png" width="500">

2. Check the loading status of rewarded video

```
var is_rewarded_ad_loaded = yodo1mas.is_rewarded_ad_loaded()
```

3. Show rewarded video
```
yodo1mas.show_rewarded_ad()
```
