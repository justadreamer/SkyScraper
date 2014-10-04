
Pod::Spec.new do |s|
  s.name             = "XH"
  s.version          = "0.1"
  s.summary          = "A wrapper over XSLT with a couple useful additions to allow you easily scrape HTML into JSON object"
  s.license          = 'MIT'
  s.author           = { "Eugene Dorfman" => "eugene.dorfman@postindustria.com" }  
  s.source           = { :git => "git@github.com:justadreamer/iOS-XSLT-HTMLScraper.git", :tag => "0.1" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'XH/*.*'
  s.homepage = 'https://github.com/justadreamer/iOS-XSLT-HTMLScraper'
  s.libraries = 'xslt', 'exslt', 'xml2'
end
