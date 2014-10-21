
Pod::Spec.new do |s|
  s.name             = "XHTransformation"
  s.version          = "0.1"
  s.summary          = "A wrapper over XSLT with a couple useful additions to allow you easily scrape HTML into JSON object"
  s.license          = { :type => "MIT", :file => "LICENSE.txt" }
  s.author           = { "Eugene Dorfman" => "eugene.dorfman@gmail.com" }  
  s.source           = { :git => "git@github.com:justadreamer/iOS-XSLT-HTMLScraper.git", :tag => "0.1" }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true
  s.source_files = 'XHTransformation/*.{h,m}'
  s.private_header_files = ['XHTransformation/libxslt/*.h','XHTransformation/libexslt/*.h']
  s.preserve_paths = 'XHTransformation/{libxslt,libexslt}'
  s.homepage = 'https://github.com/justadreamer/iOS-XSLT-HTMLScraper'
  s.libraries = 'xslt', 'exslt', 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2' }
end
