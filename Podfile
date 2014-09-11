platform :ios, '7.0'

target "StoreSearch" do
  pod 'AFNetworking', '~> 2.0'
end

# Add Application pods here

target :unit_tests, :exclusive => true do
  link_with 'UnitTests'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end
