platform :ios, '11.0'

abstract_target 'App' do
  use_frameworks!

  pod 'BrightFutures'
  pod 'GraphQLicious', '~> 0.8.2'
  pod 'OAuthSwift'
  pod 'RealmSwift'
  pod 'Result', '~> 3.2.3'
  pod 'UTIKit', '~> 2.0.1'
  pod '※ikemen'

  target 'GithubFileExtension'
  target 'OctoEye' do
    pod 'ReactiveCocoa', '~> 6.0'
    pod 'ReactiveSwift', '~> 2.0'
  end

  target 'Tests' do
    pod 'JetToTheFuture'
    pod 'Nimble'
    pod 'Quick'
  end
end

pod 'SwiftLint'

LegacySwiftPods = %w(OAuthSwift JetToTheFuture BrightFutures Quick Nimble RealmSwift ReactiveCocoa)

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if LegacySwiftPods.include? target.name
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end

      if target.name == 'OAuthSwift'
        config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
        if !config.build_settings['OTHER_SWIFT_FLAGS'].include? " \"-D\" \"OAUTH_APP_EXTENSIONS\""
          config.build_settings['OTHER_SWIFT_FLAGS'] << " \"-D\" \"OAUTH_APP_EXTENSIONS\""
        end
      end
    end
  end
end
