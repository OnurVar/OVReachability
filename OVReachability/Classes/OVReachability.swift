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
    
    //MARK: Variables
    fileprivate var completion : OVReachabilityCompletion!
    fileprivate var manager : Alamofire.NetworkReachabilityManager!
    fileprivate var urlHost : String!
    fileprivate var timeIntervalSleep = 1 //Time Interval to sleep
    
    
    
    //MARK: Initializers
    
    override init() {
        
    }
    
    public func setup(withDomain domain: String, withTimeInterval time: Int! = 1, withCompletion completion:@escaping OVReachabilityCompletion){
        self.completion = completion
        self.timeIntervalSleep = time
        if manager != nil {
            manager.stopListening()
            manager = nil
        }
        
        urlHost =  domain
        
        manager = Alamofire.NetworkReachabilityManager(host: domain)
        manager.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
                
            case .reachable(.ethernetOrWiFi),.reachable(.wwan):
                self.didChangeConnection(withConnection: true)
                break
            default:
                self.didChangeConnection(withConnection: false)
                break
            }
        }
        manager.startListening()
    }
    
    public func stopMonitoring(){
        if manager != nil {
            manager.stopListening()
        }
    }
    
    
    //MARK: Private Methods
    
    fileprivate func didChangeConnection(withConnection isConnected: Bool){
        if isConnected {
            DispatchQueue.main.async {
                var isServerReachableCurrent = false
                repeat {
                    isServerReachableCurrent = self.checkConnectivity()
                    let wasServerReachable = self.isServerReachable
                    self.isServerReachable = isServerReachableCurrent

                    
                    if false == wasServerReachable && true == isServerReachableCurrent {
                        self.completion(true)
                    }else if true == wasServerReachable && false == isServerReachableCurrent {
                        self.completion(false)
                    }
                    sleep(UInt32(self.timeIntervalSleep))
                }while( !isServerReachableCurrent );
            }
        }else{
            self.isServerReachable = false
            completion(false)
        }
    }
    
    fileprivate func checkConnectivity() -> Bool {
        guard let url = URL.init(string: String.init(format: "http://%@",urlHost)) else {
            return false
        }
        let request = URLRequest.init(url: url)
        var response: URLResponse?
        var urlData: Data?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returning:&response)
        } catch {
            print(error.localizedDescription)
        }
        return urlData != nil && response != nil
    }
    
}
