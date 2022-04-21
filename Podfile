# Uncomment the next line to define a global platform for your project
use_frameworks!
platform :ios, '13.0'

target 'MyChat' do
  workspace 'MyChat.xcworkspace'

 pod 'SwiftLint'

 pod 'Texture'
 pod 'lottie-ios'

 pod 'RxSwift'
 pod 'RxRelay'
 pod 'RxCocoa'

 pod 'FBSDKLoginKit'
 pod 'GoogleSignIn'

 pod 'Firebase'
 pod 'Firebase/Auth'
 pod 'Firebase/Messaging'
 pod 'Firebase/Firestore'
 pod 'Firebase/Analytics'
 pod 'Firebase/Crashlytics'
 pod 'Firebase/RemoteConfig'

end

target 'Services' do
  xcodeproj './Modules/Services/Services.xcodeproj'

 pod 'RxSwift'
 pod 'RxRelay'

 pod 'FBSDKLoginKit'
 pod 'GoogleSignIn'

 pod 'Firebase/Auth'
 pod 'Firebase/Firestore'
 pod 'Firebase/Messaging'
 pod 'Firebase/RemoteConfig'

end

target 'UI' do
  xcodeproj './Modules/UI/UI.xcodeproj'

 pod 'Texture'
 pod 'lottie-ios'

end

target 'Analytics' do
  xcodeproj './Modules/Analytics/Analytics.xcodeproj'

 pod 'Firebase/Analytics'

end

target 'Logger' do
  xcodeproj './Modules/Logger/Logger.xcodeproj'

 pod 'Firebase/Crashlytics'

end

post_install do |installer|
    applicationTargets = [
        'Pods-MyChat',
    ]
    libraryTargets = [
        'Pods-Services',
    ]

    embedded_targets = installer.aggregate_targets.select { |aggregate_target|
        libraryTargets.include? aggregate_target.name
    }
    embedded_pod_targets = embedded_targets.flat_map { |embedded_target| embedded_target.pod_targets }
    host_targets = installer.aggregate_targets.select { |aggregate_target|
        applicationTargets.include? aggregate_target.name
    }

    # We only want to remove pods from Application targets, not libraries
    host_targets.each do |host_target|
        host_target.xcconfigs.each do |config_name, config_file|
            host_target.pod_targets.each do |pod_target|
                if embedded_pod_targets.include? pod_target
                    pod_target.specs.each do |spec|
                        if spec.attributes_hash['ios'] != nil
                            frameworkPaths = spec.attributes_hash['ios']['vendored_frameworks']
                            else
                            frameworkPaths = spec.attributes_hash['vendored_frameworks']
                        end
                        if frameworkPaths != nil
                            frameworkNames = Array(frameworkPaths).map(&:to_s).map do |filename|
                                extension = File.extname filename
                                File.basename filename, extension
                            end
                            frameworkNames.each do |name|
                                puts "Removing #{name} from OTHER_LDFLAGS of target #{host_target.name}"
                                config_file.frameworks.delete(name)
                            end
                        end
                    end
                end
            end
            xcconfig_path = host_target.xcconfig_path(config_name)
            config_file.save_as(xcconfig_path)
        end
    end
end