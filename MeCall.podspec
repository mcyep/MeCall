#
#  Be sure to run `pod spec lint MeCall.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #
  #   The description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  #
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.name         = "MeCall"
  s.version      = "0.0.9"
  s.homepage     = "https://bitbucket.org/u2systems-ios/mecall"
  s.summary      = "A VoIP Framework for iOS App"
  s.description  = <<-DESC
MeCall is VoIP framework based on SIP protocol that can be integrate into any iOS app, extend with voice calling feature
                   DESC


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #
  s.license      = { :type => "GPLv2", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #
  # Or just: s.author    = "Yep Mun Chun"
  # s.authors            = { "Yep Mun Chun" => "munchun.yep@u2systems.com" }
  # s.social_media_url   = "http://twitter.com/Yep Mun Chun"

  s.author = { "Yep Mun Chun" => "munchun.yep@u2systems.com" }


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #
  # When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.platform = :ios, "8.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source = { :git => "https://bitbucket.org/u2systems-ios/mecall.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #
  # s.exclude_files = "Classes/Exclude"

  s.source_files         = "MeCall/**/*.{h,m}", "liblinphone-sdk/apple-darwin/include/**/*.h"
  s.public_header_files  = "MeCall/**/*.h"
  s.private_header_files = "liblinphone-sdk/apple-darwin/include/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # s.resources = "Resources/**/*"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #
  # s.framework  = "SomeFramework"
  # s.library   = "iconv"

  s.frameworks = "CoreMedia", "VideoToolbox", "AVFoundation", "AudioToolbox"
  s.libraries = "iconv", "xml2", "z", "resolv", "stdc++.6", "sqlite3"
  s.vendored_libraries = "liblinphone-sdk/apple-darwin/lib/**/*.a"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.
  #
  # s.requires_arc = true
  # s.dependency "JSONKit", "~> 1.4"
  # s.header_mappings_dir = 'src/include'
  # pod lib lint
  # s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => "/Users/u2systems/Desktop/MeCall/liblinphone-sdk/apple-darwin/include", "OTHER_LDFLAGS" => "-read_only_relocs suppress", "ENABLE_BITCODE" => "NO" }

  # Release
    s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => "${PODS_ROOT}/MeCall/liblinphone-sdk/apple-darwin/include", "OTHER_LDFLAGS" => "-read_only_relocs suppress", "ENABLE_BITCODE" => "NO" }


end
