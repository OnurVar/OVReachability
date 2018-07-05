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

    @IBOutlet weak var lblStatus : UILabel!
    
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
        self.lblStatus.text = "Disconnected"
        if let url = URL(string: "https://172.16.7.4:8445") {
            OVReachability.sharedInstance.numberOfTry = 5
            OVReachability.sharedInstance.setup(withDomain: url,withTimeInterval: 1) { (isConnected) in
                DispatchQueue.main.async {
                    self.lblStatus.text = isConnected ? "Connected" : "Disconnected"
                }
            }
        }
    }

    @IBAction func btnTriggerTapped(_ sender: Any) {
        OVReachability.sharedInstance.startMonitoring()
    }
}

