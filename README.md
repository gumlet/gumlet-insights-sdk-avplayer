# gumlet-Insights-avplayer

Gumlet Insights integration with AVPlayer for iOS native applications. This Insights enables you to get useful data about video usage in your apps. **AVPlayer** is an iOS native feature to manage the playback. AVPlayer are two approaches **AVPlayerLayer** and **AVPlayerViewController**. This integration is built on **SWIFT**, allowing thinner wrappers for player.

## Step 1: Add the SDK to the Project
Gumlet Insights is available through CocoaPods and Swift package Manager.

### Install Gumlet Insights SDK with Cocoapods
 1. Create Podfile or modify Podfile to use SDK(frameworks) by using use_frameworks!
 2. Add the pod inside the Podfile
  ```sh
   # platform :ios, '13.0'

	source 'https://github.com/gumlet/gumlet-insights-sdk-avplayer.git'

target 'InsightsDemoApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for InsightsDemoApp
	pod 'GumletInsightsSDKAVPlayer', :git => "https://github.com/gumlet/gumlet-insights-sdk-avplayer.git"



end

  ```
 3. Run **pod repo update** to add the newly added source and run **Pod install** to install it.
 4. import SDK on your file
  ```sh
   import GumletInsightsSDKAVPlayer
  ```
  
### Install Gumlet Insights SDK with Swift Package Manager(SwiftPM)
 
1. In Xcode click **“File”** > **”Swift Packages”** > **“Add Package Dependency…”**
2. The package repository URL is - https://github.com/gumlet/gumlet-insights-sdk-avplayer.git
3. Click **Next**
4. Select default **Branch** of the package **main** and click **Next**
5. Xcode downloads the Gumlet Insights package to the your app target.
6. Click **Finish**.

## Step 2: Setup the Gumlet Insights to the your app
Get Property ID from [gumlet dashboard](https://www.gumlet.com/dashboard/video/insights/properties).

With **AVPlayerViewController** use **initAVPlayerViewController** method and if you are using  **AVPlayerLayer** , use **initAVPlayerLayer** method instead.

```sh
 let playerVC = AVPlayerViewController()

 let gumletConfig = GumletInsightsConfig()
 gumletConfig.proprtyId = "Your Property ID"

 GumletInsightsSDK.initAVPlayerViewController(playerVC, config:gumletConfig)
```

## Step 3: Add additional data

Add **MetaData** as per your requirement which can elivate your Insights. It allows you to filter your analytics data based on important fields. Gumlet allows metadata for user, player and video via **GumletInsightsCustomUserData**, **GumletInsightsCustomPlayerData** and  **GumletInsightsCustomVideoData**

```sh
 let gumletConfig = GumletInsightsConfig()
 gumletConfig.proprtyId = "Your Property ID"
 
 let userData = GumletInsightsCustomUserData()
 userData.userName =“Gumlet”
 userData.userEmail = “support@gumlet.com”
 userData.userCountry = “India”

 let customVideoData = GumletInsightsCustomVideoData()
 customVideoData.customContentType = “kids”
 customVideoData.customVideoTitle = “Peppa Pig”
 customVideoData.customVideoLanguage = “English”

 let playerData = GumletInsightsCustomPlayerData()
 playerData.GumletPlayerName = “AVPlayer”  
 playerData.GumletPlayerIntegrationVersion = “1.0”
 playerData.gumletPageType = “AVPlayerViewController” 

 GumletInsightsSDK.initAVPlayerViewController(playerVC, userData: userData, customPlayerData: playerData, customVideoData: customVideoData, config: gumletConfig)
```
