#
# Be sure to run `pod lib lint LogEase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LogEase'
  s.version          = '0.1.5'
  s.summary          = 'Logger LogEase.'

  s.description      = <<-DESC
Easiest logger. This logger you can use in yours frameworks. Many logger frameworks impossible to use in own framework because you have many errors during compilation
                       DESC

  s.homepage         = 'https://github.com/sglushchenko/LogEase'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Serhii Hlushchenko' => 'glushchenko2003@gmail.com' }
  s.source           = { :git => 'https://github.com/sglushchenko/LogEase.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/LogEase/**/*'

  s.swift_versions = "5"

  s.resource_bundles = {"#{s.name}" => ['PrivacyInfo.xcprivacy']}

end
