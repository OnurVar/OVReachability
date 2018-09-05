//
//  OVReachability.swift
//  Pods
//
//  Created by Onur Var on 6/10/17.
//
//

import UIKit
import Alamofire

public enum ConnectionStatus {
    case Disconnected
    case Connected
    case StillDisconnected
    case StillConnected
}

public class OVReachability: NSObject {

    
    //MARK: TypeAlias
    public typealias OVReachabilityCompletion = (_ status: ConnectionStatus) -> Void
    
    
    //MARK: Variables
    public static let shared        = OVReachability()
    public var isServerReachable    = false
    
    //MARK: Variables
    fileprivate var completion : OVReachabilityCompletion?
    fileprivate var manager : Alamofire.NetworkReachabilityManager!
    fileprivate var domain : URL!
    fileprivate var countDisconnect = 0
    fileprivate var isCheckingConnectivity = false
    fileprivate var isEnabled = false
    
    
    //MARK: Initializers
    
    override init() {
        
    }
    
    public func setup(withDomain aDomain: URL, withCompletion aCompletion:@escaping OVReachabilityCompletion){
        
        NSLog("[OVReachability] Version (1.3.3)")
        self.completion         = aCompletion
        self.domain             = aDomain
       
        stopMonitoring()
        manager                 = nil
        
        if let host = domain.host {
            
            self.manager = Alamofire.NetworkReachabilityManager(host: host)
            manager.listener = { status in
                switch status {
                case .reachable(.ethernetOrWiFi):
                    NSLog("[OVReachability] Status Changed (Reachable Ethernet/Wifi)")
                    break
                case .reachable(.wwan):
                    NSLog("[OVReachability] Status Changed (Reachable WWAN)")
                    break
                default:
                    NSLog("[OVReachability] Status Changed (Not Reachable)")
                    break
                }
                
                //Refresh Variables
                self.countDisconnect = 0
                
                //Trigger Loop
                self.checkConnectionLoop()
                
            }
            
            manager.startListening()
            
        }
    }
    
    public func stopMonitoring(){

        if let manager = manager{
            manager.stopListening()
        }
        
        isEnabled = false
    }
    
    public func startMonitoring(){
        if isEnabled { return }
        
        isEnabled = true
        
        //Refresh Variables
        self.countDisconnect = 0
        
        //Trigger Loop
        checkConnectionLoop()
    }
    
    
    
    //MARK: Private Methods
    
    fileprivate func checkConnectionLoop(){
        if isEnabled {
            self.checkConnectivityAsync(completion: { (isConnected) in
                var isServerReachableCurrent = false
                isServerReachableCurrent = isConnected
                let wasServerReachable = self.isServerReachable
                self.isServerReachable = isServerReachableCurrent
                
                if true == wasServerReachable && true == isServerReachableCurrent {
                    self.notifyObserver(status: .StillConnected)
                    if OVReachabilityConfiguration.shared.stopWhenConnected {
                        return
                    }
                }else if false == wasServerReachable && true == isServerReachableCurrent {
                    self.notifyObserver(status: .Connected)
                    if OVReachabilityConfiguration.shared.stopWhenConnected {
                        return
                    }
                }else if true == wasServerReachable && false == isServerReachableCurrent {
                    self.notifyObserver(status: .Disconnected)
                    if OVReachabilityConfiguration.shared.numberOfTry == 0 {
                        return
                    }
                }else if false == wasServerReachable && false == isServerReachableCurrent {
                    self.countDisconnect = self.countDisconnect + 1
                    self.notifyObserver(status: .StillDisconnected)
                    if self.countDisconnect == OVReachabilityConfiguration.shared.numberOfTry {
                        return
                    }
                    NSLog("[OVReachability] Check Failed (%d times)",self.countDisconnect)
                }
                
                sleep(UInt32(OVReachabilityConfiguration.shared.timeIntervalSleep))
                self.checkConnectionLoop()
            })
        }
    }
    
    fileprivate func notifyObserver(status: ConnectionStatus){
    
        
        switch status {
        case .Connected:
            NSLog("[OVReachability] Notified (Connected)")
            isServerReachable = true
            break
        case .Disconnected:
            NSLog("[OVReachability] Notified (Disconnected)")
            isServerReachable = false
            break
        case .StillConnected:
            NSLog("[OVReachability] Notified (StillConnected)")
            isServerReachable = true
            break
        case .StillDisconnected:
            NSLog("[OVReachability] Notified (StillDisconnected)")
            isServerReachable = false
            break
        }
        DispatchQueue.main.async {
            if let completion = self.completion {
                completion(status)
            }
        }
        
    }
    
    fileprivate func checkConnectivityAsync(completion: @escaping (_ connected: Bool) -> Void) {
        
        if !isCheckingConnectivity {
            NSLog("[OVReachability] Check Connectivity (Starting)")
            
            if let domain = self.domain{
                
                // Setup the configuration
                let sessionConfiguration = URLSessionConfiguration.default
                sessionConfiguration.urlCache = nil
                sessionConfiguration.timeoutIntervalForRequest = Double(OVReachabilityConfiguration.shared.requestTimeoutInterval)
                
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
