//
//  ViewController.swift
//  CaliFire
//
//  Created by Guest account on 10/13/18.
//  Copyright © 2018 ParraIndustries. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func button(_ sender: Any) {
        
        let svc = SFSafariViewController(url: URL(string: "https://www.gofundme.com/tcb-2018-carr-fire-fund")!)
        self.present(svc, animated: true, completion: nil)
        
    }
    
}
