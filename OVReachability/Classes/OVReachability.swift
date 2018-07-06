//
//  OVReachability.swift
//  Pods
//
//  Created by Onur Var on 6/10/17.
//
//

import UIKit
import Alamofire




public class OVReachability: NSObject {

    
    //MARK: TypeAlias
    public typealias OVReachabilityCompletion = (_ connected: Bool) -> Void
    
    
    //MARK: Variables
    public static let sharedInstance = OVReachability()
    public var isServerReachable = false
    public var numberOfTry = 0
    public var timeoutInterval = 5
    
    //MARK: Variables
    fileprivate var completion : OVReachabilityCompletion!
    fileprivate var manager : Alamofire.NetworkReachabilityManager!
    fileprivate var domain : URL!
    fileprivate var timeIntervalSleep = 1 //Time Interval to sleep
    fileprivate var countDisconnect = 0
    fileprivate var isCheckingConnectivity = false
    
    
    
    //MARK: Initializers
    
    override init() {
        
    }
    
    public func setup(withDomain domain: URL, withTimeInterval time: Int! = 1, withCompletion completion:@escaping OVReachabilityCompletion){
        
        NSLog("[OVReachability] Version (1.3.1)")
        self.completion         = completion
        self.timeIntervalSleep  = time
        self.domain             = domain
       
        stopMonitoring()
        manager                 = nil
        
        
        if let host = domain.host {
            self.manager = Alamofire.NetworkReachabilityManager(host: host)

            manager.listener = { status in
                switch status {
                    
                case .reachable(.ethernetOrWiFi):
                    NSLog("[OVReachability] Status Changed (Reachable Ethernet/Wifi)")
                    self.checkConnectionLoop()
                    break
                case .reachable(.wwan):
                    NSLog("[OVReachability] Status Changed (Reachable WWAN)")
                    self.checkConnectionLoop()
                    break
                default:
                    NSLog("[OVReachability] Status Changed (Not Reachable)")
                    self.notifyObserver(isConnected: false)
                    break
                }
            }
            startMonitoring()
        }
    }
    
    public func stopMonitoring(){
        if let manager = manager{
            manager.stopListening()
        }
    }
    
    public func startMonitoring(){
        if let manager = manager{
            manager.startListening()
        }
    }
    
    
    //MARK: Private Methods
    
    fileprivate func checkConnectionLoop(){
        self.checkConnectivityAsync(completion: { (isConnected) in
            var isServerReachableCurrent = false
            isServerReachableCurrent = isConnected
            let wasServerReachable = self.isServerReachable
            self.isServerReachable = isServerReachableCurrent
            
            if true == wasServerReachable && true == isServerReachableCurrent {
                return
            }else if false == wasServerReachable && true == isServerReachableCurrent {
                self.notifyObserver(isConnected: true)
                return
            }else if true == wasServerReachable && false == isServerReachableCurrent {
                if self.numberOfTry == 0 {
                    self.notifyObserver(isConnected: false)
                    return
                }
            }else if false == wasServerReachable && false == isServerReachableCurrent {
                self.countDisconnect = self.countDisconnect + 1
                if self.countDisconnect == self.numberOfTry {
                    self.notifyObserver(isConnected: false)
                    return
                }
                NSLog("[OVReachability] Check Failed (%d times)",self.countDisconnect)
            }
            
            sleep(UInt32(self.timeIntervalSleep))
            self.checkConnectionLoop()
        })
    }
    
    fileprivate func notifyObserver(isConnected: Bool){
        
        //Refresh Variables
        self.countDisconnect = 0
        
        isServerReachable = isConnected
        completion(isConnected)
        
        NSLog("[OVReachability] Notified (%@)",isConnected ? "Connected" : "Disconnected")
        
    }
    
    fileprivate func checkConnectivityAsync(completion: @escaping (_ connected: Bool) -> Void) {
        
        if !isCheckingConnectivity {
            NSLog("[OVReachability] Check Connectivity (Starting)")
            
            if let domain = self.domain{
                
                // Setup the configuration
                let sessionConfiguration = URLSessionConfiguration.default
                sessionConfiguration.urlCache = nil
                sessionConfiguration.timeoutIntervalForRequest = Double(timeoutInterval)
                
                // initialize the URLSession
                let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue())
                
                // create a URLSessionDataTask with the given URL
                isCheckingConnectivity = true
                let task = session.dataTask(with: domain) { (data, response, error) in
                    self.isCheckingConnectivity = false
                    let success = (error == nil && response != nil)
                    NSLog(String(format: "[OVReachability] Check Connectivity (Stopped : %@)", success ? "Success" : "Failed" ))
                    completion(success)
                }
                task.resume()
            }
        }
       
    }
}

extension OVReachability : URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential.init(trust: challenge.protectionSpace.serverTrust!))
    }

}
