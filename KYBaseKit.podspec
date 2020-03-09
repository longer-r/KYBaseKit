#
# Be sure to run `pod lib lint KYBaseKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KYBaseKit'
  s.version          = '1.1.7'
  s.summary          = 'A short description of KYBaseKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitee.com/kyd_iOSGroup/KYBaseKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'longer' => '504010900@qq.com' }
  s.source           = { :git => 'https://gitee.com/kyd_iOSGroup/KYBaseKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  ## 工程特殊性--使用源码居多，故默认操作加载源码方式引入
  if ENV['IS_Binary_SOURCE']# 引用二进制库
    puts '-------------------------------------------------------------------'
    puts 'Notice:KYBaseKit is binary now'

    # framework (推荐) -- 通过pod package生成静态库
    s.public_header_files = 'Pod/Products/*.framework/Headers/*'
    s.ios.vendored_frameworks = 'Pod/Products/*.framework'
    # # lib 
    # s.public_header_files = 'Pod/Products/include/*.h'
    # s.ios.vendored_libraries = 'Pod/Products/lib/*.a'
  else
    puts '-------------------------------------------------------------------'
    puts 'Notice: KYBaseKit is source now'

    s.source_files = 'KYBaseKit/Classes/**/*'
    s.prefix_header_contents = '#import "KYBaseKit.h"'
  end
  
  # s.resource_bundles = {
  #   'KYBaseKit' => ['KYBaseKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
