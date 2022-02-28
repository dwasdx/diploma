# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ShopList' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwipeCellKit'
  pod 'PhoneNumberKit'
  # Pods for ShopList

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
      cflags << '-fembed-bitcode'
      config.build_settings['OTHER_CFLAGS'] = cflags
    end
  end
end