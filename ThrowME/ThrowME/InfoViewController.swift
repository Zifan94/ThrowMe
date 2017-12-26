//
//  InfoViewController.swift
//  ThrowME
//
//  Created by Zifan  Yang on 12/26/17.
//  Copyright © 2017 Zifan  Yang. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var InfoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add shadow to the info image
        self.InfoImage.layer.shadowColor = UIColor.black.cgColor
        self.InfoImage.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.InfoImage.layer.shadowOpacity = 1.0
        self.InfoImage.layer.shadowRadius = 14.0
        self.InfoImage.clipsToBounds = false
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
