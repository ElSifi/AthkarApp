# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'DailyAthkar' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DailyAthkar
  pod 'SwipeCellKit'
  pod 'DLLocalNotifications'
  pod 'OneSignal'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Firestore'
  pod 'FirebaseUI/Auth'
  pod 'Siren'
  pod 'Firebase/Database'
  pod 'BadgeHub'
  pod 'Firebase/Analytics'
  #for google analytics thing
end

target 'OneSignalNotificationServiceExtension' do
    use_frameworks!
    pod 'OneSignal'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
    end
  end
end
