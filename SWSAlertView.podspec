Pod::Spec.new do |s|

  s.name         = "SWSAlertView"
  s.version      = "0.0.3"
  s.summary      = "A short description of SWSAlertView."
  s.description  = <<-DESC
    这是一个简单自定义的弹框！
                   DESC
  s.homepage     = "http://EXAMPLE/SWSAlertView"
  s.license      = "MIT"
  s.author             = { "shiwensong" => "18996601419@189.cn" }
  s.source       = { :git => "https://github.com/shiwensong/SWSAlertView.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.requires_arc = true
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.dependency 'SDAutoLayout', '2.2.0'
  s.dependency 'FDFullscreenPopGesture', '1.1'
end
