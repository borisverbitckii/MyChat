# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
use_frameworks!

def google_utilites
  pod 'GoogleUtilities/AppDelegateSwizzler'
  pod 'GoogleUtilities/Environment'
  pod 'GoogleUtilities/ISASwizzler'
  pod 'GoogleUtilities/Logger'
  pod 'GoogleUtilities/MethodSwizzler'
  pod 'GoogleUtilities/NSData+zlib'
  pod 'GoogleUtilities/Network'
  pod 'GoogleUtilities/Reachability'
  pod 'GoogleUtilities/UserDefaults'
  pod 'GTMSessionFetcher'
end

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
 pod 'Firebase/Storage'
 pod 'FirebaseDatabase'
 pod 'Firebase/Messaging'
 pod 'Firebase/RemoteConfig'
 pod 'Firebase/Analytics'
 pod 'Firebase/Crashlytics'

 pod 'Periphery'

 google_utilites
end

target 'Services' do
  xcodeproj './Modules/Services/Services.xcodeproj'

 pod 'RxSwift'
 pod 'RxRelay'

 pod 'FBSDKLoginKit'
 pod 'GoogleSignIn'

 pod 'Firebase'
 pod 'Firebase/Auth'
 pod 'Firebase/Storage'
 pod 'FirebaseDatabase'
 pod 'Firebase/Messaging'
 pod 'Firebase/RemoteConfig'

 pod 'Periphery'

 google_utilites

 pod 'SwiftLint'
end

target 'UI' do
  xcodeproj './Modules/UI/UI.xcodeproj'

 pod 'Texture'
 pod 'lottie-ios'

 pod 'SwiftLint'
end

target 'Messaging' do
  xcodeproj './Modules/Messaging/Messaging.xcodeproj'

 pod 'RxSwift'
 pod 'RxRelay'
 pod 'Periphery'

 pod 'SwiftLint'
end

target 'Analytics' do
  xcodeproj './Modules/Analytics/Analytics.xcodeproj'

 pod 'Firebase/Analytics'
 pod 'Periphery'

 google_utilites

 pod 'SwiftLint'
end

target 'Logger' do
  xcodeproj './Modules/Logger/Logger.xcodeproj'

 pod 'Firebase/Crashlytics'
 pod 'Periphery'

 google_utilites

 pod 'SwiftLint'
end

target 'Models' do
  xcodeproj './Modules/Models/Models.xcodeproj'
 pod 'SwiftLint'
end


post_install do |installer|
  removeOTHERLDFLAGS(['MyChat', 'Services'], installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end



def removeOTHERLDFLAGS(target_names, installer)
  pods_targets_names = target_names.map{ |str| 'Pods-' + str }
  handle_app_targets(pods_targets_names, installer)
end

def find_line_with_start(str, start)
  str.each_line do |line|
    if line.start_with?(start)
      return line
    end
  end
  return nil
end

def remove_words(str, words)
  new_str = str
  words.each do |word|
    new_str = new_str.sub(word, '')
  end
  return new_str
end

def handle_app_targets(names, installer)
  puts "handle_app_targets"
  puts "names: #{names}"
  installer.pods_project.targets.each do |target|
    if names.index(target.name) == nil
      next
    end
    puts "Updating #{target.name} OTHER_LDFLAGS"
    target.build_configurations.each do |config|
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      old_line = find_line_with_start(xcconfig, "OTHER_LDFLAGS")
      
      if old_line == nil
        next
      end
      new_line = ""
      new_xcconfig = xcconfig.sub(old_line, new_line)
      File.open(xcconfig_path, "w") { |file| file << new_xcconfig }
    end
  end
end