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
    @IBOutlet weak var StartStatusText: UITextField!
    
    @IBOutlet weak var UserStatusText: UITextView!
    
    @IBOutlet weak var StartButton: UIButton!
    
    var isSteady:Bool = false
    var isStill:Bool = false
    var currentColor:String = "red"
    var rotator_err: Double = 0.06
    var state:String = "None"
    
    let motionActivityManager = CMMotionActivityManager()
    let motionManager = CMMotionManager()
    let altimeter = CMAltimeter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.StartButton.isEnabled = false
        self.StartStatusText.text = "Not started"
        self.state = "searching_1"
        //get User status
        startActivityUpdates()
    }
    
    @IBAction func StartButtonTapped(_ sender: Any) {
        if(self.state == "wait_for_tap_2") {
            self.StartStatusText.text = "Started"
            self.state = "started_3"
            //record initial height and time here///////////////////
            
            self.state = "in_air_4"
        }
    }
    
    func startActivityUpdates() {
        //machine support status
        guard CMMotionActivityManager.isActivityAvailable() else {
            self.UserStatusText.text = "\nThis phone is too old to use this App\n"
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
            self.UserStatusText.text = text
            self.currentColor = self.checkSteadyAndStill()
        })
    }
    
    func checkSteadyAndStill() -> String{
        if(self.state != "searching_1" && self.state != "wait_for_tap_2") {
            return "None"
        }
        if(self.isStill == true && self.isSteady == true) {
            self.StartButton.alpha = 1
            self.StartButton.isEnabled = true
            self.StartButton.backgroundColor = UIColor(displayP3Red: 0.0, green: 255.0/255.0, blue: 0.0, alpha: 1)
            self.state = "wait_for_tap_2"
            return "green"
        }
        else if(self.isStill == true || self.isSteady == true) {
            self.StartButton.alpha = 0.4
            self.StartButton.isEnabled = false
            self.StartButton.backgroundColor = UIColor(displayP3Red: 255.0/255.0, green: 255.0/255.0, blue: 0.0, alpha: 1)
            return "yellow"
        }
        else {
            self.StartButton.alpha = 0.4
            self.StartButton.isEnabled = false
            self.StartButton.backgroundColor = UIColor(displayP3Red: 255.0/255.0, green: 0.0, blue: 0.0, alpha: 1)
            return "red"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

