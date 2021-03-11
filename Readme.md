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

Now we need to compile a library for our future xCode project.
[Here](https://docs.godotengine.org/en/stable/development/compiling/compiling_for_ios.html) is an official documentation about plugin compilation in godot.
1. Open **Terminal** program on your Mac.
2. Navigate to godot repository folder. For example, if you clone godot repository godot-3.2.3-stable in Downloads folder then use this commands:
  - **cd**. This command navigates you to your home folder.
  - **cd Downloads/godot-3.2.3-stable**. Navigates to godot folder.
  - **ls**. Display all files in godot folder.
<img src="/images/terminal_navigates_to_godot.png" width="500">
3. Compile the engine for iOs platform. Type commands in the terminal

  - scons p=iphone tools=no target=release arch=arm
  - scons p=iphone tools=no target=release arch=arm64
  - lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a -output bin/libgodot.iphone.release.fat.a

You can compile only for arm or arm64 version. Just use one command. 
Compiled ios library will end up in bin folder.
<img src="/images/compiled_ios_lib.png" width="500">

For iOs platform you need only script yodo1mas.gd from our demo project. It is wrapper for all MAS functions.
Below we provide an example how to compile demo project on iOs. You will be able to compile your poject in the same way.

1. Export the project for iOs platform. 
<img src="/images/export_ios.png" width="500">
After that you can use Export PCK/Zip to replace only *.pck file.*
2. Here is a directory with xcode project. For now GodotYodo1Mas.a file is a library of godot engine but without Yodo1 MAS SDK. 
You already compiled a required library before.
<img src="/images/godot_ios_libraries.png" width="500">
Now rename file _libgodot.iphone.opt.arm64.a_ to _GodotYodo1Mas.a_ and copy-paste it to Godot xCode project.
Now library  _GodotYodo1Mas.a_ in xCode project contains MAS SDK wrapper.
3. Use cocoapods to add all MAS SDKs in your xCode project. Create




