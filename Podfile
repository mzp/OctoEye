platform :ios, '11.0'

abstract_target 'App' do
  use_frameworks!

  pod 'BrightFutures'
  pod 'GraphQLicious', '~> 0.8.2'
  pod 'RealmSwift'
  pod 'Result', '~> 3.2.3'
  pod 'UTIKit', '~> 2.0.1'
  pod '※ikemen'

  target 'GithubFileExtension'
  target 'OctoEye'

  target 'Tests' do
    pod 'JetToTheFuture'
    pod 'Nimble'
    pod 'Quick'
  end
end

pod 'SwiftLint'

LegacySwiftPods = %w(JetToTheFuture BrightFutures Quick Nimble)

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if LegacySwiftPods.include? target.name
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
