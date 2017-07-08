platform :ios, '11.0'

abstract_target 'App' do
  use_frameworks!

  pod 'BrightFutures'
  pod 'GraphQLicious', '~> 0.8.2'
  pod 'Result', '~> 3.2.3'
  pod 'UTIKit', '~> 2.0.1'
  pod 'RealmSwift'

  target 'GithubFileExtension'
  target 'OctoEye'
end

pod 'SwiftLint'

LegacySwiftPods = %w(BrightFutures)

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if LegacySwiftPods.include? target.name
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
