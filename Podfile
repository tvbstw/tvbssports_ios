source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

target 'tvbssports' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'AlamofireObjectMapper'
  pod 'SnapKit'
  pod 'KingfisherWebP', '~> 1.4.0'
  pod 'Kingfisher', '~> 7.6.1'
  pod 'DateToolsSwift'
  pod 'IQKeyboardManagerSwift'
  pod 'CocoaLumberjack/Swift'
  pod 'ReachabilitySwift'
  pod 'MBProgressHUD'
  pod 'MJRefresh'
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'ComScore'
  pod 'XLPagerTabStrip', '~> 9.0.0'
  pod 'Toast-Swift'
  pod 'MarqueeLabel'
  pod 'KeychainAccess'
  pod 'CryptoSwift'
  pod 'FMDB'
  pod 'SSZipArchive'
  pod 'GDPerformanceView-Swift'
  pod 'StepSlider'
  pod 'SwiftDate'
  pod 'CHTCollectionViewWaterfallLayout'
  pod 'FSPagerView'

  
  pod 'XCDYouTubeKit', :git => 'https://github.com/Candygoblen123/XCDYouTubeKit'
  
  # pod 'AWSCore'
  # pod 'AWSKinesis'
  # pod 'AWSMobileClient'  # Required dependency
  # pod 'AWSAuthUI'      # Optional dependency required to use drop-in UI
  # pod 'AWSUserPoolsSignIn'
  
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'
  # Pods for tvbssports

  target 'tvbssportsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'tvbssportsUITests' do
    # Pods for testing
  end

end

target 'tvbssports dev' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'AlamofireObjectMapper'
  pod 'SnapKit'
  pod 'KingfisherWebP', '~> 1.4.0'
  pod 'Kingfisher', '~> 7.6.1'
  pod 'DateToolsSwift'
  pod 'IQKeyboardManagerSwift'
  pod 'CocoaLumberjack/Swift'
  pod 'ReachabilitySwift'
  pod 'MBProgressHUD'
  pod 'MJRefresh'
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'ComScore'
  pod 'XLPagerTabStrip', '~> 9.0.0'
  pod 'Toast-Swift'
  pod 'MarqueeLabel'
  pod 'KeychainAccess'
  pod 'CryptoSwift'
  pod 'FMDB'
  pod 'SSZipArchive'
  pod 'GDPerformanceView-Swift'
  pod 'StepSlider'
  pod 'SwiftDate'
  pod 'CHTCollectionViewWaterfallLayout'
  pod 'FSPagerView'
  
  pod 'XCDYouTubeKit', :git => 'https://github.com/Candygoblen123/XCDYouTubeKit'
  
  # pod 'AWSCore'
  # pod 'AWSKinesis'
  # pod 'AWSMobileClient'  # Required dependency
  # pod 'AWSAuthUI'      # Optional dependency required to use drop-in UI
  # pod 'AWSUserPoolsSignIn'
  
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'
  # Pods for tvbssports dev

end

post_install do |installer|
        installer.pods_project.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
end
