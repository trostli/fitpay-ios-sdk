# Fitpay iOS SDK - README.md


## Using the SDK
Fitpay distributes the SDK via cocoapods and carthage. Documentation on using **cocoapods** can be found [here](https://guides.cocoapods.org/using/getting-started.html) and for **carthage** [here](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos). 
#### Cocoapods
Currently we are using cocoapods v1.1.1

Once you have set up your project to use cocoapods, add the following to your Podfile:
```
ruby
pod 'FitpaySDK'
```

#### Carthage
Once you have set up your project to use carthage, add the following to your Cartfile:
```
ruby
github "fitpay/fitpay-ios-sdk" "develop"
```
After that you should follow to default carthage workflow, which is:

1. Execute next command:  ```$carthage update --platform iOS```
1. On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop all frameworks from the Carthage/Build folder on disk.
1. On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: `bin/sh`), add the following contents to the script area below the shell:

  ```sh
  /usr/local/bin/carthage copy-frameworks
  ```
  and add the paths to the frameworks you want to use under “Input Files”, e.g.:
 
  ```
  $(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
  $(SRCROOT)/Carthage/Build/iOS/AlamofireObjectMapper.framework
  $(SRCROOT)/Carthage/Build/iOS/JWTDecode.framework
  $(SRCROOT)/Carthage/Build/iOS/KeychainAccess.framework
  $(SRCROOT)/Carthage/Build/iOS/ObjectMapper.framework
  $(SRCROOT)/Carthage/Build/iOS/FitpaySDK.framework
  ```


## Building the SDK locally

```
sudo gem install cocoapods
cd ~  
mkdir fitpay
cd fitpay  
git clone git@github.com:fitpay/fitpay-ios-sdk.git
cd fitpay-ios-sdk
pod install  
```
Open Xcode (currently using Xcode 8.2), and add a project (->Open another project->/users/yourname/fipay/fitpay-ios-sdk)  

Select the **FitpaySDK-Universal** build under Product->Scheme. Ensure that the scheme is set to build for Generic iOS Device.
## Using a local pod
In the project Podfile, change the following line:
```ruby
pod ‘FitpaySDK’
````
to be:
```ruby 
pod ‘FitpaySDK’, :path => ‘~/fitpay/fitpay-ios-sdk’  
```

Fit-Pay also utilizes a continuous integration system (travis) to build and test. Current Develop Branch Status: [![Build Status](https://travis-ci.org/fitpay/fitpay-ios-sdk.svg?branch=develop)](https://travis-ci.org/fitpay/fitpay-ios-sdk)


## Running Tests Locally from XCode UI
Open the project inside of Xcode
Filemenu -> View, Navigators, Show Test Navigators
Right click on FitpaySDK tests, Enable tests
Click on a test, and press "Play"

## Running Tests From the Commandline
By default the tests will run in the iPhone 7 simulator.
```
./bin/test
```
To test on a different simulator, pass in a valid simulator same.
```
./bin/test "iPhone 5s"
```



## Contributing to the SDK
We welcome contributions to the SDK. For your first few contributions please fork the repo, make your changes and submit a pull request. Internally we branch off of develop, test, and PR-review the branch before merging to develop (moderately stable). Releases to Master happen less frequently, undergo more testing, and can be considered stable. For more information, please read:  [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)

## License
This code is licensed under the MIT license. More information can be found in the [LICENSE](LICENSE) file contained in this repository.

## Questions? Comments? Concerns?
Please contact the team via a github issue, OR, feel free to email us: sdk@fit-pay.com

