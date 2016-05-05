platform :ios, '8.0'
use_frameworks!

target 'FitpaySDK' do
    pod 'AlamofireObjectMapper', '~> 2.1.2'
    pod 'JWTDecode', '~> 1.0.0'
    pod 'libPusher', '~> 1.6.1'
    pod 'KeychainAccess', '~> 2.3.4'
    pod 'FPCrypto', :git => 'https://github.com/fitpay/FPCrypto.git', :branch => :master
end

target 'FitpaySDKDemo' do
    pod 'AlamofireObjectMapper', '~> 2.1.2'
    pod 'JWTDecode', '~> 1.0.0'
    pod 'libPusher', '~> 1.6.1'
    pod 'KeychainAccess', '~> 2.3.4'
    pod 'FPCrypto', :git => 'https://github.com/fitpay/FPCrypto.git', :branch => :master
end

target 'FitpaySDKTests' do
    pod 'AlamofireObjectMapper', '~> 2.1.2'
    pod 'JWTDecode', '~> 1.0.0'
    pod 'libPusher', '~> 1.6.1'
    pod 'KeychainAccess', '~> 2.3.4'
end

target 'RTMClientApp' do
    pod 'AlamofireObjectMapper', '~> 2.1.2'
    pod 'JWTDecode', '~> 1.0.0'
    pod 'libPusher', '~> 1.6.1'
    pod 'KeychainAccess', '~> 2.3.4'
    pod 'FPCrypto', :git => 'https://github.com/fitpay/FPCrypto.git', :branch => :master
end

target 'ObjCDemo' do
    pod 'AlamofireObjectMapper', '~> 2.1.2'
    pod 'JWTDecode', '~> 1.0.0'
    pod 'libPusher', '~> 1.6.1'
    pod 'KeychainAccess', '~> 2.3.4'
    pod 'FPCrypto', :git => 'https://github.com/fitpay/FPCrypto.git', :branch => :master
end

post_install do |installer|
  `cp module.modulemap ./Pods/FPCrypto/source/`
end