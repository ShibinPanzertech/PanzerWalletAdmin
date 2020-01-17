//
//  TimerApplication.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 6/1/20.
//  Copyright © 2020 test.com. All rights reserved.
//

import UIKit
import Foundation

extension Notification.Name {
    
    static let appTimeout = Notification.Name("appTimeout")
    
}
class TimerApplication: UIApplication {
    static let ApplicationDidTimoutNotification = "AppTimout"
    // the timeout in seconds, after which should perform custom actions
    // such as disconnecting the user
     var timeoutInSeconds: TimeInterval {
        // 5 minutes
        return 5 * 60
    }
    
     var idleTimer: Timer?
    
    // resent the timer because there was user interaction
     func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(TimerApplication.timeHasExceeded),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    
    // if the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
         print("Time Out")
        NotificationCenter.default.post(name:Notification.Name.appTimeout, object: nil)
       
    }
    
    override func sendEvent(_ event: UIEvent) {
        
        super.sendEvent(event)
        
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouch.Phase.began {
                self.resetIdleTimer()
            }
        }
    }
}
