# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'myCuisine' do
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Pods for Flash Chat
pod 'Firebase'
pod 'Firebase/Auth'
pod 'SVProgressHUD'
pod 'ChameleonFramework'
pod 'Firebase/Core'
pod 'Firebase/Firestore', :inhibit_warnings => true
pod 'Alamofire'
pod 'SwiftyJSON'
pod 'SearchTextField'
pod 'SDWebImage'
pod 'Hero'
pod 'SwiftEntryKit', '1.0.1'
pod 'EZYGradientView', :git => 'https://github.com/Niphery/EZYGradientView'
pod 'Segmentio', '~> 3.3'
pod 'SwipeCellKit'
pod 'DGElasticPullToRefresh'
pod 'FBSDKLoginKit'
pod 'PromiseKit', '~> 6.8'
pod 'BBBadgeBarButtonItem'
end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
end
end
end
