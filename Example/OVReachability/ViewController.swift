//
//  ViewController.swift
//  OVReachability
//
//  Created by Onur Var on 06/10/2017.
//  Copyright (c) 2017 Onur Var. All rights reserved.
//

import UIKit
import OVReachability

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupReachability(){
        OVReachability.defaultManager.setup(withDomain: "www.google.com") { (isConnected) in
            DispatchQueue.main.async {
                if isConnected {
                    UIAlertView.init(title: "Attention", message: "Connected", delegate: nil, cancelButtonTitle: "OK").show()
                }else{
                    UIAlertView.init(title: "Attention", message: "Disconnected", delegate: nil, cancelButtonTitle: "OK").show()
                }
            }
        }
    }

}

