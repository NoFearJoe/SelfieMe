project 'SelfieMe.xcodeproj'

platform :ios, '9.0'

target 'SelfieMePro' do
  use_frameworks!
  inherit! :search_paths

  pod 'RxSwift', '~> 3.0.0-beta.1'
  pod 'RxCocoa', '~> 3.0.0-beta.1'
  pod 'Google/Analytics'
  pod 'GoogleMobileAds'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'GPUImage'

end

target 'SelfieMe' do
  use_frameworks!
  inherit! :search_paths

  pod 'RxSwift', '~> 3.0.0-beta.1'
  pod 'RxCocoa', '~> 3.0.0-beta.1'
  pod 'Google/Analytics'
  pod 'GoogleMobileAds'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'GPUImage'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IOS_DEPLOYMENT_TARGET'] = '9.0'
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
