# xcconfig settings
TREE_MAP_XCCONFIG = {
	'CLANG_CXX_LANGUAGE_STANDARD' => 'compiler-default',
	'CLANG_CXX_LIBRARY' => 'compiler-default',

	# Don't ignore compile warnings!
	'GCC_TREAT_WARNINGS_AS_ERRORS' => 'YES',
	'SWIFT_TREAT_WARNINGS_AS_ERRORS' => 'YES',

	'DEFINES_MODULE' => 'YES',

	'OTHER_CFLAGS' => '-Wall -Wextra -Wno-unused-parameter',
}

Pod::Spec.new do |s|
  s.name         = "KTDTreeMap"
  s.version      = "0.0.1"
  s.summary      = "TreeMap display in CollectionView for iOS."
  s.homepage     = "https://github.com/kydonnelly/KTDTreeMap"

  s.license      = {
    :type => 'Mozilla Public License 2.0',
  }

  s.author       = { "Kyle Donnelly" => "kydonnelly@gmail.com" }
  s.source         = { :git => "https://github.com/kydonnelly/KTDTreeMap.git", :branch => "master", :tag => s.version }

  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.pod_target_xcconfig = TREE_MAP_XCCONFIG
  
  s.module_name = 'KTDTreeMap'
  s.swift_version = '5'
  
  s.subspec 'core' do |c|
      c.source_files = 'KTDTreeMap/Classes/**/*.{swift}'
  end

  s.requires_arc = true

  s.prefix_header_contents = <<-DESC
    #ifdef __OBJC__
      #import <Foundation/Foundation.h>
    #endif
  DESC

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'KTDTreeMapTests/*.{swift}'
  end

end
