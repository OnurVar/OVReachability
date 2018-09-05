//
//  OVReachabilityConfiguration.swift
//  Pods
//
//  Created by Onur Var on 5.09.2018.
//

import UIKit

public class OVReachabilityConfiguration: NSObject {

    public static let shared            = OVReachabilityConfiguration()
    public var stopWhenConnected        = true
    public var numberOfTry              = 0
    public var requestTimeoutInterval   = 5
    public var timeIntervalSleep        = 1 //Time Interval to sleep
    
}
