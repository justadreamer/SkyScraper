
Pod::Spec.new do |s|
  s.name             = "SkyScraper"
  s.version          = "0.35"
  s.summary          = "An Objective-C wrapper over libxslt with a couple of useful additions, created to allow easy HTML scraping with data represented in JSON format with the following deserialization into application models"
  s.license          = { :type => "MIT", :file => "LICENSE.txt" }
  s.author           = { "Eugene Dorfman" => "eugene.dorfman@gmail.com" }  
  s.source           = { :git => "git@github.com:justadreamer/SkyScraper.git", :tag => s.version }

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
        'libxslt/*.h',
        'libexslt/*.h'
        ]
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2 ' }
    ss.libraries = 'xml2', 'iconv'
    ss.vendored_library = 'libxslt-with-plugins/libxslt-with-plugins.a'
    ss.private_header_files = ['libxslt/*.h','libexslt/*.h']
  end

  s.subspec 'AFNetworking2' do |ss|
    ss.dependency 'SkyScraper/Base'
    ss.dependency 'AFNetworking', '~> 2.6.3'
    ss.source_files = [
      'SkyScraper/SkyScraper+AFNetworking.h',
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
    ss.source_files = [
      'SkyScraper/SkyMantleModelAdapter.{h,m}',
      'SkyScraper/SkyScraper+Mantle.h'
    ]
  end
end
