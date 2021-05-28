# The Forks&Spoons Mobile App

Forks&Spoons is an imaginary restaurant that uses this mobile app here for online delivery. The app is developed with Flutter and it showcases following HMS (Huawei Mobile Services) Kits: Push Kit, Account Kit, AGCrash Service, Map Kit, Location Kit, Analytics Kit. 

You can access the supporting medium article from the links below:
- Integrating Huawei Crash, Push Kit and Account Kit to Forks & Spoons: A Restaurant App - Part 1
- Integrating Huawei Analytics, Map and Location Flutter Plugins to Forks & Spoons : A Restaurant App - Part 2
<img src="/.docs/ss1.png" width = 40% height = 40% style="margin:1.5em; margin-right:50px"><img src="/.docs/ss3.png" width = 40% height = 40% style="margin:1.5em">
## How to run the app

To build and run the app:
- First you need to create an app in [**AppGallery Connect**](https://developer.huawei.com/consumer/en/service/josp/agc/index.html#/) and change the **package_name** in the **build.gradle** file to the package name of the app that you've created, you can also use an existing app for this step. 
- Add your **agconnect-services.json** file to the project's **android/app** directory.
- Configure your keystore information in the **build.gradle** file
- Each HMS Plugin may need configuration so be sure check the medium article or the official documentations on the [Huawei Developers Website](https://developer.huawei.com/consumer/en/doc/development/HMS-Plugin-Guides/introduction-0000001050176002?ha_source=hms1) first.

Once everything is ready, you can run the project with:
```bash
cd <project_dir>/forks-and-spoons-restaurant-app

flutter run
```



