Pod::Spec.new do |s|
  s.name                    = 'OVReachability'
  s.version                 = '1.3.2'
  s.summary                 = 'An Improved Reachability which actually checks url'
  s.description             = <<-DESC
The original reachability class just checks the first hop on the way to the Host. If you have VPN connection, It doesn't check if we have actually connection to the Host. Well this class does. It actually tries to connect every x second to the Host until it has a valid connection.
                       DESC
  s.homepage                = 'https://github.com/OnurVar/OVReachability.git'
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.author                  = { 'Onur Var' => 'var.onur@hotmail.com' }
  s.source                  = { :git => 'https://github.com/OnurVar/OVReachability.git', :tag => s.version.to_s }
  s.ios.deployment_target   = '8.0'
  s.source_files            = 'OVReachability/Classes/**/*'
  s.dependency 'Alamofire'
end
