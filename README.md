![OVReachability](Resource/logo.png)

[![Build Status](https://travis-ci.org/OnurVar/OVReachability.svg?branch=master)](https://travis-ci.org/OnurVar/OVReachability)

The original reachability class just checks the first hop on the way to the Host. If you have VPN connection, It doesn't check if we have actually connection to the Host. Well this class does. It actually tries to connect every x second to the Host until it has a valid connection.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 8.0

## Installation

OVReachability is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OVReachability"
```

## License

OVReachability is available under the MIT license. See the LICENSE file for more info.
