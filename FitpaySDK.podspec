Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.name = 'FitpaySDK'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Swift based library for the Fitpay Platform'
  s.homepage = 'https://github.com/fitpay/fitpay-ios-sdk'
  s.authors = { 'Ben Walford' => 'ben@fit-pay.com' }
  s.source = { :git => 'https://github.com/fitpay/fitpay-ios-sdk.git', :tag => s.version }
  s.source_files = 'FitpaySDK/**/*.swift'
  s.dependency 'Alamofire', '~> 3.0'
end
