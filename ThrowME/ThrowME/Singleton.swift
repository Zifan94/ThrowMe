//
//  Singleton.swift
//  ThrowME
//
//  Created by Zifan  Yang on 12/28/17.
//  Copyright © 2017 Zifan  Yang. All rights reserved.
//

import Foundation
class Singleton {
    
    var text: String!
    
    private static let _singleton = Singleton()
    
    class func sharedInstance() ->Singleton {
        return _singleton
    }
    
    private init() {
    }
}
