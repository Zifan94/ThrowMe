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
    
    @IBOutlet weak var StabilityBox: UITextField!
    
    @IBOutlet weak var RetryButton: UIButton!
    
    @IBOutlet weak var WifiView: UIImageView!
    
    @IBOutlet weak var StabilizationStatusText: UILabel!
    
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
        
        //self.state = "searching_1"
        initializing()
    }
    
    @IBAction func StartButtonTapped(_ sender: Any) {
        if(self.state == "wait_for_tap_2") {
            //stop stability checking
            self.motionActivityManager.stopActivityUpdates()
            //self.StartStatusText.text = "Started"
            self.state = "started_3"
            
            //disable the StartButton and change the button text into "Throw Me!"
            self.StartButton.isEnabled = false
            
            //self.StartButton.backgroundColor = UIColor(displayP3Red: 0.0, green: 255.0/255.0, blue: 0.0, alpha: 0.4)
//            self.InstructionPicture.image = UIImage(named:"wait_for_throw.png")
            self.StabilizationStatusText.text = ""
            
            //start height checking and get the value in ThrowDistance
            startRelativeAltitudeUpdates()
            
            //stablizing
            self.state = "wait_for_stablizing_4"
            startActivityUpdates()
            
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
            //update HeightText/////////////////////////////////////////
            self.HeightText.text = text
            //update the throw distance/////////////////////////////////
            if(currentHeight >= preHeight) {
                preHeight = currentHeight
            }
            else {
                self.ThrowDistance = preHeight
                print("\(preHeight)")
                //self.StartStatusText.text = "\(preHeight)"
                self.altimeter.stopRelativeAltitudeUpdates()
            }
            
        })
    }
    
    
    func checkSteadyAndStill() -> String{
        if(self.state == "searching_1" || self.state == "wait_for_tap_2") {
            if(self.isStill == true && self.isSteady == true) {
                self.StartButton.alpha = 0.6
                self.StartButton.isEnabled = true
                self.StabilityBox.backgroundColor = GREEN
                self.state = "wait_for_tap_2"
                self.WifiView.image = UIImage(named:"wifi_high.png")
                self.StabilizationStatusText.text = " HIGH "
                self.StabilizationStatusText.backgroundColor = GREEN
                self.StabilizationStatusText.textColor = WHITE
                return "green"
            }
            else if(self.isStill == true || self.isSteady == true) {
                self.StartButton.alpha = 0.4
                self.StartButton.isEnabled = false
                self.StabilityBox.backgroundColor = YELLOW
                self.WifiView.image = UIImage(named:"wifi_medium.png")
                self.StabilizationStatusText.text = " MEDIUM "
                self.StabilizationStatusText.backgroundColor = YELLOW
                self.StabilizationStatusText.textColor = WHITE
                return "yellow"
            }
            else {
                self.StartButton.alpha = 0.4
                self.StartButton.isEnabled = false
                self.StabilityBox.backgroundColor = RED
                self.WifiView.image = UIImage(named:"wifi_low.png")
                self.StabilizationStatusText.text = " LOW "
                self.StabilizationStatusText.backgroundColor = RED
                self.StabilizationStatusText.textColor = WHITE
                return "red"
            }
        }
        else if(self.state == "wait_for_stablizing_4") {
            if(self.isStill == true && self.isSteady == true) {
                self.StabilityBox.backgroundColor = GREEN
                self.state = "stablized_5"
                self.WifiView.image = UIImage(named:"wifi_high.png")
                self.StabilizationStatusText.text = " HIGH "
                self.StabilizationStatusText.backgroundColor = GREEN
                self.StabilizationStatusText.textColor = WHITE
                self.motionActivityManager.stopActivityUpdates()
                return "green"
            }
            else if(self.isStill == true || self.isSteady == true) {
                self.StabilityBox.backgroundColor = YELLOW
                self.WifiView.image = UIImage(named:"wifi_medium.png")
                self.StabilizationStatusText.text = " MEDIUM "
                self.StabilizationStatusText.backgroundColor = YELLOW
                self.StabilizationStatusText.textColor = WHITE
                return "yellow"
            }
            else {
                self.StabilityBox.backgroundColor = RED
                self.WifiView.image = UIImage(named:"wifi_low.png")
                self.StabilizationStatusText.text = " LOW "
                self.StabilizationStatusText.backgroundColor = RED
                self.StabilizationStatusText.textColor = WHITE
                return "red"
            }
        }
        else {
            self.StabilityBox.backgroundColor = UIColor(displayP3Red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.4)
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
        //self.StartStatusText.text = "Not started"
        self.StartButton.setTitle("Start", for: .normal)
        self.WifiView.image = UIImage(named:"wifi_low.png")
        self.state = "searching_1"
        self.StabilizationStatusText.text = ""
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

