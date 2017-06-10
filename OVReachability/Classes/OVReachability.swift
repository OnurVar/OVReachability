//
//  OVReachability.swift
//  Pods
//
//  Created by Onur Var on 6/10/17.
//
//

import UIKit
import AFNetworking




public class OVReachability: NSObject {

    
    //MARK: TypeAlias
    public typealias OVReachabilityCompletion = (_ connected: Bool) -> Void
    
    
    //MARK: Variables
    public static let defaultManager = OVReachability()
    var completion : OVReachabilityCompletion!
    fileprivate var manager : AFHTTPSessionManager!
    fileprivate var urlHost : URL!
    var isServerReachable = false
    
    
    public static func getit(){}
    
    //MARK: Initializers
    
    override init() {
        
    }
    
    public func setup(withDomain domain: String,withCompletion completion: @escaping OVReachabilityCompletion){
        if let url = URL.init(string: domain){
            self.setup(withDomainURL: url, withCompletion: completion)
        }
    }
    
    public func setup(withDomainURL domain: URL, withCompletion completion:@escaping OVReachabilityCompletion){
        self.completion = completion
        if manager != nil {
            manager.reachabilityManager.stopMonitoring()
            manager = nil
        }
        
        urlHost = domain
        manager = AFHTTPSessionManager.init(baseURL: urlHost)
        manager.reachabilityManager.setReachabilityStatusChange { (status) in
            switch status{
            case .reachableViaWiFi,.reachableViaWWAN:
                self.didChangeConnection(withConnection: true)
                break
            default:
                self.didChangeConnection(withConnection: false)
                break
            }
        }
        manager.reachabilityManager.startMonitoring()
    }
    
    func stopMonitoring(){
        if manager != nil {
            manager.reachabilityManager.stopMonitoring()
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
                }while( !isServerReachableCurrent );
            }
        }else{
            self.isServerReachable = false
            completion(false)
        }
    }
    
    fileprivate func checkConnectivity() -> Bool {
        let request = URLRequest.init(url: urlHost)
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
