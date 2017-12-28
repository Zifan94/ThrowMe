//
//  ResultViewController.swift
//  ThrowME
//
//  Created by Zifan  Yang on 12/28/17.
//  Copyright © 2017 Zifan  Yang. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButton.layer.shadowColor = UIColor.white.cgColor
        self.backButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.backButton.layer.shadowOpacity = 1.0
        self.backButton.layer.shadowRadius = 17.0
        self.backButton.clipsToBounds = false
        
        self.downloadButton.layer.shadowColor = UIColor.white.cgColor
        self.downloadButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.downloadButton.layer.shadowOpacity = 1.0
        self.downloadButton.layer.shadowRadius = 17.0
        self.downloadButton.clipsToBounds = false
        
        let singleton = Singleton.sharedInstance()
        print("/////////////")
        print(singleton.text)
        print("/////////////")
    }

    @IBAction func goBackTapped(_ sender: Any) {
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainVC") as! ViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
