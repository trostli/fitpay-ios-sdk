# Fitpay iOS SDK - README.md


## Building the app locally
Ensure you have cocoapods installed, and the repo checked out:
```shell
sudo gem install cocoapods  
cd ~  
mkdir fitpay
cd fitpay  
git clone git@github.com:fitpay/fitpay-ios-sdk.git
cd fitpay-ios-sdk
pod install  
```
Open XCode, and add a project (->Open another project->/users/yourname/fipay/fitpay-ios-sdk)  

Fit-Pay also utilizes a continuous integration system (travis) to build and test. Current Develop Branch Status: [![Build Status](https://travis-ci.org/fitpay/fitpay-ios-sdk.svg?branch=develop)](https://travis-ci.org/fitpay/fitpay-ios-sdk)


## Running Tests Locally from XCode UI
Open the project inside of XCode
Filemenu -> View, Navigators, Show Test Navigators
Right click on FitpaySDK tests, Enable tests
Click on a test, and press "Play"

## Running Tests From the Commandline
```
xcodebuild test -project FitpaySDK.xcodeproj -scheme FitpaySDK -destination 'platform=iOS Simulator,name=iPhone 6s'
```


## Contributing to the SDK
We welcome contributions to the SDK. For your first few contributions please fork the repo, make your changes and submit a pull request. Internally we branch off of develop, test, and PR-review the branch before merging to develop (moderately stable). Releases to Master happen less frequently, undergo more testing, and can be considered stable. For more information, please read:  [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)

## License
This code is licensed under the MIT license. More information can be found in the [LICENSE](LICENSE) file contained in this repository.

## Questions? Comments? Concerns?
Please contact the team via a github issue, OR, feel free to email us: sdk@fit-pay.com


