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
    
    @IBOutlet weak var ResultImage: UIImageView!
    
    @IBOutlet weak var HeightLabel: UILabel!
    
    @IBOutlet weak var stageText: UILabel!
    
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
        let orgHeightStr = singleton.text
        var Height = (orgHeightStr! as NSString).doubleValue
        Height = Height * 100.0
        if Height<0  {
            Height = 0
        }
        
        if Height<11 {
            self.ResultImage.image = UIImage(named:"lvl_1.png")
            self.stageText.text = "Stage 1"
        }
        else if Height<31 {
            self.ResultImage.image = UIImage(named:"lvl_2.png")
            self.stageText.text = "Stage 2"
        }
        else if Height<61 {
            self.ResultImage.image = UIImage(named:"lvl_3.png")
            self.stageText.text = "Stage 3"
        }
        else if Height<101 {
            self.ResultImage.image = UIImage(named:"lvl_4.png")
            self.stageText.text = "Stage 4"
        }
        else if Height<131 {
            self.ResultImage.image = UIImage(named:"lvl_5.png")
            self.stageText.text = "Stage 5"
        }
        else if Height<161 {
            self.ResultImage.image = UIImage(named:"lvl_6.png")
            self.stageText.text = "Stage 6"
        }
        else if Height<201 {
            self.ResultImage.image = UIImage(named:"lvl_7.png")
            self.stageText.text = "Stage 7"
        }
        else if Height>=201 {
            self.ResultImage.image = UIImage(named:"lvl_fi.png")
            self.stageText.text = "Stage 8"
        }
        
        let finalHeightStr = String(format: "%.2f", Height)
        self.HeightLabel.text = finalHeightStr+" CM"
        

        
        print("/////////////")
        print(singleton.text)
        print(finalHeightStr)
        print("/////////////")
    }

    @IBAction func goBackTapped(_ sender: Any) {
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainVC") as! ViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func saveImageToAlbum(_ sender: Any) {
        self.backButton.isHidden = true
        self.downloadButton.isHidden = true
        
        self.screenSnapshot(save: true)
        
        self.backButton.isHidden = false
        self.downloadButton.isHidden = false
        //UIImageWriteToSavedPhotosAlbum(self.ResultImage.image!, "image:didFinishSavingWithError:contextInfo: ", nil, nil)
    }
    
//    func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject) {
//        if didFinishSavingWithError != nil {
//            print("error!")
//            return
//        }
//        print("image was saved")
//    }
    
    func screenSnapshot(save: Bool) -> UIImage? {
        guard let window = UIApplication.shared.keyWindow else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if save { UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil) }
        return image
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
