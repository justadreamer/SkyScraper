
Pod::Spec.new do |s|
  s.name             = "SkyScraper"
  s.version          = "0.18"
  s.summary          = "An Objective-C wrapper over libxslt with a couple of useful additions, created to allow an easy HTML scraping into JSON with the following deserialization into application models"
  s.license          = { :type => "MIT", :file => "LICENSE.txt" }
  s.author           = { "Eugene Dorfman" => "eugene.dorfman@gmail.com" }  
  s.source           = { :git => "git@github.com:justadreamer/SkyScraper.git", :commit => "HEAD" }
  s.ios.deployment_target = '7.0'
  s.requires_arc 	 = true
  s.homepage 		 = 'https://github.com/justadreamer/SkyScraper'
  s.default_subspec  = 'All'
  
  s.subspec 'All' do |ss|
    ss.dependency 'SkyScraper/AFNetworking2'
    ss.dependency 'SkyScraper/Mantle'
  end

  s.subspec 'Base' do |ss|
    ss.source_files = [
        'SkyScraper/SkyScraper.h',
        'SkyScraper/SkyXSLTransformation.{h,m}',
        'SkyScraper/SkyXSLTParams.{h,m}',
        'SkyScraper/SkyModelAdapter.h',        
        ]
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2 ' }
    ss.libraries = 'xml2', 'iconv'
    ss.dependency 'SkyScraper/libxslt-with-plugins'
  end

  s.subspec 'libxslt-with-plugins' do |ss|
    ss.vendored_library = 'libxslt-with-plugins/libxslt-with-plugins.a'
    ss.public_header_files = ['libxslt/*.h','libexslt/*.h']
    ss.preserve_paths = ['libxslt/*.h','libexslt/*.h']
  end

  s.subspec 'AFNetworking2' do |ss|
    ss.dependency 'SkyScraper/Base'
    ss.dependency 'AFNetworking', '~> 2.4.1'
    ss.source_files = [
      'SkyScraper/SkyResponseSerializer+Protected.h',
      'SkyScraper/SkyHTMLResponseSerializer.{h,m}',
      'SkyScraper/SkyXMLResponseSerializer.{h,m}',
      'SkyScraper/SkyJSONResponseSerializer.{h,m}',
      'SkyScraper/SkyResponseSerializer.{h,m}'
    ]
  end

  s.subspec 'Mantle' do |ss|
    ss.dependency 'SkyScraper/Base'
    ss.dependency 'Mantle'
    ss.source_files = 'SkyScraper/SkyMantleModelAdapter.{h,m}'
  end
end
