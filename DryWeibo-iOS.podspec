#
# Be sure to run `pod lib lint DryWeibo-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# 提交仓库:
# pod spec lint DryWeibo-iOS.podspec --allow-warnings --use-libraries
# pod trunk push DryWeibo-iOS.podspec --allow-warnings --use-libraries
#

Pod::Spec.new do |s|
  
  # Git
  s.name        = 'DryWeibo-iOS'
  s.version     = '1.0.0'
  s.summary     = 'DryWeibo-iOS'
  s.homepage    = 'https://github.com/duanruiying/DryWeibo-iOS'
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.author      = { 'duanruiying' => '2237840768@qq.com' }
  s.source      = { :git => 'https://github.com/duanruiying/DryWeibo-iOS.git', :tag => s.version.to_s }
  s.description = <<-DESC
  TODO: iOS简化微博集成(授权、获取用户信息、分享).
  DESC
  
  # User
  #s.swift_version          = '5.0'
  s.ios.deployment_target   = '10.0'
  s.requires_arc            = true
  s.user_target_xcconfig    = {'OTHER_LDFLAGS' => ['-w']}
  
  # Pod
  s.static_framework        = true
  s.pod_target_xcconfig     = {'OTHER_LDFLAGS' => ['-w', '-ObjC']}
  
  # Code
  s.source_files        = 'DryWeibo-iOS/Classes/Code/**/*'
  s.public_header_files = 'DryWeibo-iOS/Classes/Code/Public/**/*.h'
  
  # System
  #s.libraries  = 'z', 'c++', 'iconv', 'sqlite3'
  s.frameworks = 'UIKit', 'Foundation'
  
  # ThirdParty
  #s.vendored_libraries  = ''
  #s.vendored_frameworks = 'DryWeibo-iOS/Classes/Frameworks/*.framework'
  s.dependency 'Weibo_SDK'
  
end
