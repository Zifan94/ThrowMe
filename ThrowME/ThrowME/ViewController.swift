//
//  ViewController.swift
//  ThrowME
//
//  Created by Zifan  Yang on 12/20/17.
//  Copyright © 2017 Zifan  Yang. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //@IBOutlet weak var StartStatusText: UITextField!
    
    //@IBOutlet weak var UserStatusText: UITextView!
    
    @IBOutlet weak var StartButton: UIButton!
    
    @IBOutlet weak var HeightText: UITextView!
    
    @IBOutlet weak var RetryButton: UIButton!
    
    @IBOutlet weak var WifiView: UIImageView!
    
    @IBOutlet weak var StabilizationStatusText: UILabel!
    
    @IBOutlet weak var PressButtonHint: UILabel!
    
    @IBOutlet weak var ThrowPhoneHint: UILabel!
    
    @IBOutlet weak var RecalHint: UILabel!
    
    @IBOutlet weak var RecaliStatusHint: UILabel!
    
    @IBOutlet weak var RecaliStatus: UILabel!
    
    @IBOutlet weak var ComCompleteHint: UILabel!
    
    @IBOutlet weak var CMDView: UIImageView!
    
    var isSteady:Bool = false
    var isStill:Bool = false
    var currentColor:String = "red"
    var rotator_err: Double = 0.06
    var state:String = "None"
    var ThrowDistance:Double = -100.0
    
    let motionActivityManager = CMMotionActivityManager()
    let motionManager = CMMotionManager()
    let altimeter = CMAltimeter()
    
    let WHITE = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    let GREEN = UIColor(displayP3Red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1)
    let YELLOW = UIColor(displayP3Red: 255.0/255.0, green: 215.0/255.0, blue: 0.0, alpha: 1)
    let RED = UIColor(displayP3Red: 255.0/255.0, green: 48.0/255.0, blue: 48.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CMDView.layer.shadowColor = UIColor.black.cgColor
        self.CMDView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.CMDView.layer.shadowOpacity = 1.0
        self.CMDView.layer.shadowRadius = 8.0
        self.CMDView.clipsToBounds = false
        
        //self.state = "searching_1"
        initializing()
    }
    
    @IBAction func StartButtonTapped(_ sender: Any) {
        if(self.state == "wait_for_tap_2") {
            //stop stability checking
            self.motionActivityManager.stopActivityUpdates()
            self.state = "started_3"
            
            //disable the StartButton and change the button text into "Throw Me!"
            self.StartButton.isEnabled = false
            self.StartButton.isHidden = false
            
            self.ThrowPhoneHint.isHidden = false
            self.StabilizationStatusText.text = " DONE "
            self.StabilizationStatusText.backgroundColor = GREEN
            self.StabilizationStatusText.textColor = WHITE
            
            //self.StartButton.backgroundColor = UIColor(displayP3Red: 0.0, green: 255.0/255.0, blue: 0.0, alpha: 0.4)
            
            //start height checking and get the value in ThrowDistance
            startRelativeAltitudeUpdates()
            
            //stablizing
            
            
            //device stablized, state became "stablized_5"
            //now we can show user the result.
            
        }
    }
    
    func startActivityUpdates() {
        //machine support status
        guard CMMotionActivityManager.isActivityAvailable() else {
            //self.UserStatusText.text = "\nThis phone is too old to use this App\n"
            return
        }
        if(self.state == "wait_for_stablizing_4") {
            self.RecalHint.isHidden = false
            self.RecaliStatusHint.isHidden = false
            self.RecaliStatus.isHidden = false
        }
        //initializing and getting data
        let queue = OperationQueue.current
        self.motionActivityManager.startActivityUpdates(to: queue!, withHandler: {
            activity in
            //get motion data///////////////////////////////////
            var text = "---motion Activity Data---\n"
            text += "Current State: \(activity!.getDescription())\n"
            if (activity!.confidence == .low) {
                text += "Accuracy: low\n"
            } else if (activity!.confidence == .medium) {
                text += "Accuracy: medium\n"
            } else if (activity!.confidence == .high) {
                text += "Accuracy: high\n"
            }
            //update isStill
            if(activity!.getDescription() == "Still"){//} && activity!.confidence != .low) {
                self.isStill = true
            }
            else {
                self.isStill = false
            }

            //pull rotator data///////////////////////////////////
            self.motionManager.startGyroUpdates()
            var total_error:Double = 100.0
        
            if let gyroData = self.motionManager.gyroData {
                let rotationRate = gyroData.rotationRate
                total_error = fabs(rotationRate.x)+fabs(rotationRate.y)+fabs(rotationRate.z)
                let rotator_x = "\(rotationRate.x)"
                let rotator_y = "\(rotationRate.y)"
                let rotator_z = "\(rotationRate.z)"
                
                text += "---rotator data---\n"
                text += "x: "+rotator_x+"\n"
                text += "y: "+rotator_y+"\n"
                text += "z: "+rotator_z+"\n"
            }
            //update isSteady
            if(total_error<=self.rotator_err)
            {
                self.isSteady = true
            }
            else {
                self.isSteady = false
            }
            
            //update UserStatusText///////////////////////////////////
            //self.UserStatusText.text = text
            self.currentColor = self.checkSteadyAndStill()
        })
    }
    
    
    func startRelativeAltitudeUpdates() {
        //initialization and get data
        let height_queue = OperationQueue.current
        var preHeight:Double = 0.0
        self.altimeter.startRelativeAltitudeUpdates(to: height_queue!, withHandler: {
            (altitudeData, error) in
            //get height data////////////////////////////////////////////
            guard error == nil else {
                print(error!)
                return
            }
            let currentHeight = altitudeData!.relativeAltitude.doubleValue
            var text = "---Height data---\n"
            text += "relative Altitude: \(currentHeight) m\n"
            
            //update the throw distance/////////////////////////////////
            if((currentHeight-preHeight)>=(-0.01)) {
                preHeight = currentHeight
            }
            else {
                self.ThrowDistance = preHeight
                print("\(preHeight)")
                //self.altimeter.stopRelativeAltitudeUpdates()
                
                self.state = "wait_for_stablizing_4"
                self.startActivityUpdates()
            }
            
        })
    }
    
    
    func checkSteadyAndStill() -> String{
        if(self.state == "searching_1" || self.state == "wait_for_tap_2") {
            if(self.isStill == true && self.isSteady == true) {
                self.StartButton.isEnabled = true
                self.StartButton.isHidden = false
                self.state = "wait_for_tap_2"
                self.WifiView.image = UIImage(named:"wifi_high.png")
                self.StabilizationStatusText.text = " HIGH "
                self.StabilizationStatusText.backgroundColor = GREEN
                self.StabilizationStatusText.textColor = WHITE
                self.PressButtonHint.isHidden = false
                return "green"
            }
            else if(self.isStill == true || self.isSteady == true) {
//                self.StartButton.isHidden = true
                self.StartButton.isEnabled = false
                self.WifiView.image = UIImage(named:"wifi_medium.png")
                self.StabilizationStatusText.text = " MEDIUM "
                self.StabilizationStatusText.backgroundColor = YELLOW
                self.StabilizationStatusText.textColor = WHITE
                self.PressButtonHint.isHidden = true
                return "yellow"
            }
            else {
//                self.StartButton.isHidden = true
                self.StartButton.isEnabled = false
                self.WifiView.image = UIImage(named:"wifi_low.png")
                self.StabilizationStatusText.text = " LOW "
                self.StabilizationStatusText.backgroundColor = RED
                self.StabilizationStatusText.textColor = WHITE
                self.PressButtonHint.isHidden = true
                return "red"
            }
        }
        else if(self.state == "wait_for_stablizing_4") {
            if(self.isStill == true && self.isSteady == true) {
                self.state = "stablized_5"
                self.WifiView.image = UIImage(named:"wifi_high.png")
                self.RecaliStatus.text = " HIGH "
                self.RecaliStatus.backgroundColor = GREEN
                self.RecaliStatus.textColor = WHITE
                self.motionActivityManager.stopActivityUpdates()
                Thread.sleep(forTimeInterval: 0.3)
                self.RecaliStatus.text = " DONE "
                Thread.sleep(forTimeInterval: 0.3)
                self.ComCompleteHint.isHidden = false
                
                self.altimeter.stopRelativeAltitudeUpdates()
                self.motionActivityManager.stopActivityUpdates()
                ///////////////////////////////////
                //// show result //////////////////
                self.HeightText.text = "\(self.ThrowDistance)"
                
                let singleton = Singleton.sharedInstance()
                singleton.text = "\(self.ThrowDistance)"
                
                let sb = UIStoryboard(name:"Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "ResultVC") as! ResultViewController
                self.present(vc, animated: true, completion: nil)
                
                ///////////////////////////////////
                ///////////////////////////////////
                return "green"
            }
            else if(self.isStill == true || self.isSteady == true) {
                self.WifiView.image = UIImage(named:"wifi_medium.png")
                self.RecaliStatus.text = " MEDIUM "
                self.RecaliStatus.backgroundColor = YELLOW
                self.RecaliStatus.textColor = WHITE
                return "yellow"
            }
            else {
                self.WifiView.image = UIImage(named:"wifi_low.png")
                self.RecaliStatus.text = " LOW "
                self.RecaliStatus.backgroundColor = RED
                self.RecaliStatus.textColor = WHITE
                return "red"
            }
        }
        else {
            return "None"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //initial the state machine and the sensors
    func initializing() {
        self.StartButton.isEnabled = false
//        self.StartButton.isHidden = true

        self.WifiView.image = UIImage(named:"wifi_low.png")
        self.state = "searching_1"
        self.StabilizationStatusText.text = ""
        self.RecaliStatus.text = ""
        self.HeightText.text = "waiting for throw"
        
        self.PressButtonHint.isHidden = true
        self.ThrowPhoneHint.isHidden = true
        self.RecalHint.isHidden = true
        self.RecaliStatusHint.isHidden = true
        self.RecaliStatus.isHidden = true
        self.ComCompleteHint.isHidden = true
        
        startActivityUpdates()
    }
    
    @IBAction func RetryButtonTapped(_ sender: Any) {
        initializing()
    }
    
    
}

extension CMMotionActivity {
    /// get user motion description
    func getDescription() -> String {
        if self.stationary {
            return "Still"
        } else if self.walking {
            return "Your are now walking"
        } else if self.running {
            return "Your are now running"
        } else if self.automotive {
            return "Your are now driving"
        }else if self.cycling {
            return "Your are now riding"
        }
        return "Unknown motion"
    }
}

