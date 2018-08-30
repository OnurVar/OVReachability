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
        if let url = URL(string: "https://www.google.com") {
            OVReachability.sharedInstance.numberOfTry           = -1
            OVReachability.sharedInstance.setup(withDomain: url, withTimeInterval: 5) { (status) in
                switch status {
                case .Connected:
                    self.lblStatus.text = "Connected"
                    break
                case .Disconnected:
                    self.lblStatus.text = "Disconnected"
                    break
                case .StillConnected:
                    self.lblStatus.text = "Still Connected"
                    break
                case .StillDisconnected:
                    self.lblStatus.text = "Still Disconnected"
                    break
                }
            }
        }
    }

    @IBAction func btnStartTapped(_ sender: Any) {
        OVReachability.sharedInstance.startMonitoring()
    }
    
    @IBAction func btnStopTapped(_ sender: Any) {
        OVReachability.sharedInstance.stopMonitoring()
    }
    
}

