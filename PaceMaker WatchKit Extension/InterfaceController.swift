//
//  InterfaceController.swift
//  PaceMaker WatchKit Extension
//
//  Created by 山上忍 on 2019/09/21.
//  Copyright © 2019 山上忍. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion


class InterfaceController: WKInterfaceController {

    var bpm: Int = 120
    var timer: Timer?
    var session: WKExtendedRuntimeSession?
    
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var beatSwitch: WKInterfaceSwitch!

    let kUserDefaultBpm = "bpm"

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
 
        let savedBpm = UserDefaults.standard.integer(forKey: kUserDefaultBpm)
        if savedBpm > 0 {
            bpm = savedBpm
        }
        label?.setText("\(bpm)")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval:  60 / TimeInterval(bpm), repeats: true) { _ in
            WKInterfaceDevice.current().play(WKHapticType(rawValue: 6)!)
        }
    }
    
    private func update() {
        if timer != nil {
            start()
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func onClickedDown() {
        bpm = max(bpm - 1, 1)
        UserDefaults.standard.set(bpm, forKey: kUserDefaultBpm)
        label.setText("\(bpm)")
        update()
    }
    
    @IBAction func onClickedUp() {
        bpm = min(bpm + 1, 250)
        UserDefaults.standard.set(bpm, forKey: kUserDefaultBpm)
        label.setText("\(bpm)")
        update()
    }
    
    @IBAction func switchAction(value: Bool) {
        if value {
            if session == nil {
                session = WKExtendedRuntimeSession()
                session?.delegate = self
                session?.start()
            }
        } else {
            session?.invalidate()
            session = nil
            stop()
        }
    }
    
}


extension InterfaceController: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        start()
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        beatSwitch.setOn(false)
        stop()
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        beatSwitch.setOn(false)
        stop()
    }
}
