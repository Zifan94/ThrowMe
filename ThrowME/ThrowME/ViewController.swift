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

    @IBOutlet weak var UserStatusText: UITextView!
    
    @IBOutlet weak var StartButton: UIButton!
    
    let motionActivityManager = CMMotionActivityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.StartButton.isEnabled = false
        //get User status
        startActivityUpdates()
    }
    
    @IBAction func StartButtonTapped(_ sender: Any) {
        print("Starting!")
    }
    
    func startActivityUpdates() {
        //machine support status
        guard CMMotionActivityManager.isActivityAvailable() else {
            self.UserStatusText.text = "\nThis phone is too old to use this App\n"
            return
        }
        
        //初始化并开始实时获取数据
        let queue = OperationQueue.current
        self.motionActivityManager.startActivityUpdates(to: queue!, withHandler: {
            activity in
            //获取各个数据
            var text = "---motion Activity Data---\n"
            text += "Current State: \(activity!.getDescription())\n"
            if (activity!.confidence == .low) {
                text += "Accuracy: low\n"
            } else if (activity!.confidence == .medium) {
                text += "Accuracy: medium\n"
            } else if (activity!.confidence == .high) {
                text += "Accuracy: high\n"
            }
            self.UserStatusText.text = text
            if(activity!.getDescription() == "Steady" && activity!.confidence != .low) {
                self.StartButton.alpha = 1
                self.StartButton.isEnabled = true
            }
            else {
                self.StartButton.alpha = 0.4
                self.StartButton.isEnabled = false
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension CMMotionActivity {
    /// 获取用户设备当前所处环境的描述
    func getDescription() -> String {
        if self.stationary {
            return "Steady"
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

