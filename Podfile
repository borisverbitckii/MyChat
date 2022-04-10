# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MyChat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  workspace 'MyChat.xcworkspace'
  pod 'Texture', '>= 2.0'
  pod 'RxSwift', '>=6.5.0'
  pod 'RxRelay', '>=6.5.0'
  pod 'SwiftLint'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'

end

target 'Services' do
  project './Modules/Services/Services.xcodeproj'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'RxSwift', '>=6.5.0'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'

end

target 'UI' do
  project './Modules/UI/UI.xcodeproj'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Texture', '>= 2.0'

end