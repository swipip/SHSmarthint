
Pod::Spec.new do |spec|


  spec.name         = "SmartHint"
  spec.version      = "1.0.4"
  spec.summary      = "Hightlight specific actions in your app with banners and callout"
  spec.description  = "SmartHint lets you add banners and callout bellow any view in your hierarchy. Ideal for first walkthrough and hint for complex tasks"
  spec.homepage     = "https://github.com/swipip/SHSmarthint"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license      = "MIT"
  spec.author             = { "Gautier Billard" => "gautier.billard@gmail.com" }
  # spec.social_media_url   = "https://twitter.com/Gautier Billard"
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/swipip/SHSmarthint.git", :tag => "1.0.4" }
  spec.source_files  = "SmartHint/**/*"
  spec.exclude_files = "SmartHint/**/*.plist"
  spec.swift_versions = "5.3"



  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
