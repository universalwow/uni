
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '15.1'
use_frameworks!

install! 'cocoapods',
            :warn_for_unused_master_specs_repo => false

target 'FilterTheWorld' do
  # Comment the next line if you don't want to use dynamic frameworks
      pod 'Alamofire'
      pod 'GoogleMLKit/PoseDetection', '2.3.0'

    pod 'GoogleMLKit/PoseDetectionAccurate', '2.3.0'
    pod 'GoogleMLKit/ObjectDetection', '2.3.0'
    pod 'AlertToast'
    pod 'NavigationStack'
        pod 'PerspectiveTransform'
	pod "SwiftPhoenixClient", '~> 5.1'


  


end


post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
        end
    end
end
