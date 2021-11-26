Pod::Spec.new do |s|

  s.name         = "react-native-plugin-zhugeio"
  s.version      = "2.0.1"
  s.summary      = "React Native modules of zhugeio using Zhugeio pod."

  s.homepage     = "https://github.com/zhugesdk/react-native-plugin-zhugeio"
  s.license      = "Apache-2.0"
  s.author       = { "Zhugeio" => "sunxiaosong@zhugeio.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/zhugesdk/react-native-plugin-zhugeio", :tag => "#{s.version}" }

  s.source_files  = "ios/*"
  s.requires_arc = true

  s.dependency "ZhugeioAnalytics"  
  s.dependency "React"
end