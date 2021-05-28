platform :ios, '12.0'
use_frameworks!

target 'TeamsEmbediOSGettingStarted' do

pod 'AzureCommunicationCommon', '1.0.0'

end

azure_libs = [
'AzureCommunicationCommon',
'AzureCore']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if azure_libs.include?(target.name)
      puts "Adding BUILD_LIBRARY_FOR_DISTRIBUTION to #{target.name}"
      target.build_configurations.each do |config|
        xcconfig_path = config.base_configuration_reference.real_path
        File.open(xcconfig_path, "a") {|file| file.puts "BUILD_LIBRARY_FOR_DISTRIBUTION = YES"}
      end
    end
  end
end
