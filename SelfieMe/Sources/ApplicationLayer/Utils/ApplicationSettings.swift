//
//  ApplicationSettings.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 18.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


class ApplicationSettings {
    
    
    class func isEnabled(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func valueForKey(_ key: String) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key) as AnyObject?
    }
    
    class func setValue(_ value: AnyObject, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    class func openPhotoImmediately() -> Bool {
        return ApplicationSettings.isEnabled("settings_general_open_photo_immediately")
    }
    
    class func setOpenPhotoImmediately(_ flag: Bool) {
        UserDefaults.standard.set(flag, forKey: "settings_general_open_photo_immediately")
        UserDefaults.standard.synchronize()
    }
    
    class func addLogo() -> Bool {
        return ApplicationSettings.isEnabled("settings_general_add_logo")
    }
    
    class func setAddLogo(_ flag: Bool) {
        UserDefaults.standard.set(flag, forKey: "settings_general_add_logo")
        UserDefaults.standard.synchronize()
    }
    
    
    class func vibrationEnabled() -> Bool {
        return ApplicationSettings.isEnabled("settings_assistant_vibration")
    }
    
    class func setVibrationEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "settings_assistant_vibration")
        UserDefaults.standard.synchronize()
    }
    
    class func screenAssistantEnabled() -> Bool {
        return ApplicationSettings.isEnabled("settings_assistant_screen")
    }
    
    class func setScreenAssistantEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "settings_assistant_screen")
        UserDefaults.standard.synchronize()
    }
    
    class func torchAssistantEnabled() -> Bool {
        return ApplicationSettings.isEnabled("settings_assistant_torch")
    }
    
    class func torchScreenAssistantEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "settings_assistant_torch")
        UserDefaults.standard.synchronize()
    }
    
    
    
    class func soundSet() -> String {
        return UserDefaults.standard.string(forKey: "settings_assistant_soundset") ?? "Default"
    }
    
    class func setSoundSet(_ name: String) {
        UserDefaults.standard.set(name, forKey: "settings_assistant_soundset")
        UserDefaults.standard.synchronize()
    }
    
    
    
    class func isFirstRun() -> Bool {
        return (UserDefaults.standard.object(forKey: "settings_general_is_first_run") as? Bool) ?? true
    }
    
    class func setFirstRun(_ flag: Bool) {
        UserDefaults.standard.set(flag, forKey: "settings_general_is_first_run")
        UserDefaults.standard.synchronize()
    }
    
    class func isEducationPresented() -> Bool {
        return (UserDefaults.standard.object(forKey: "settings_general_is_education_presented") as? Bool) ?? false
    }
    
    class func setEducationPresented(_ flag: Bool) {
        UserDefaults.standard.set(flag, forKey: "settings_general_is_education_presented")
        UserDefaults.standard.synchronize()
    }
    
    class func isRated() -> Bool {
        return (UserDefaults.standard.object(forKey: "selfieme_app_rate") as? Bool) ?? false
    }
    
    class func setRated(_ rated: Bool) {
        UserDefaults.standard.set(rated, forKey: "selfieme_app_rate")
        UserDefaults.standard.synchronize()
    }
    
    
    
    class func currentAdNumber() -> Int {
        return UserDefaults.standard.integer(forKey: "settings_ad_number")
    }
    
    class func setCurrentAdNumber(_ number: Int) {
        UserDefaults.standard.set(number, forKey: "settings_ad_number")
        UserDefaults.standard.synchronize()
    }
    
    class func adAnswerRecieved() -> Bool {
        return (UserDefaults.standard.object(forKey: "ad_answer_recieved") ?? true) as! Bool
    }
    
    class func setAdAnswerRecieved(_ flag: Bool) {
        UserDefaults.standard.set(flag, forKey: "ad_answer_recieved")
        UserDefaults.standard.synchronize()
    }
    
    
    
    class func HDRState() -> SettingState {
        let value = (UserDefaults.standard.object(forKey: "settings_camera_hdr") as? Int) ?? 0
        return SettingState(rawValue: value) ?? SettingState.auto
    }
    
    class func setHDRState(_ state: SettingState) {
        UserDefaults.standard.set(state.rawValue, forKey: "settings_camera_hdr")
        UserDefaults.standard.synchronize()
    }
    
    class func flashState() -> SettingState {
        let value = (UserDefaults.standard.object(forKey: "settings_camera_flash") as? Int) ?? 0
        return SettingState(rawValue: value) ?? SettingState.off
    }
    
    class func setFlashState(_ state: SettingState) {
        UserDefaults.standard.set(state.rawValue, forKey: "settings_camera_flash")
        UserDefaults.standard.synchronize()
    }
    
    class func timerState() -> SettingTimerState {
        let value = (UserDefaults.standard.object(forKey: "settings_camera_timer") as? Int) ?? 1
        return SettingTimerState(rawValue: value) ?? SettingTimerState._1s
    }
    
    class func setTimerState(_ state: SettingTimerState) {
        UserDefaults.standard.set(state.rawValue, forKey: "settings_camera_timer")
        UserDefaults.standard.synchronize()
    }
    
    class func cameraMode() -> CaptureResolution {
        let value = (UserDefaults.standard.object(forKey: "settings_camera_mode") as? Int) ?? 1
        return CaptureResolutions()[value]
    }
    
    class func setCaptureResolution(_ mode: CaptureResolution) {
        UserDefaults.standard.set(mode.id, forKey: "settings_camera_mode")
        UserDefaults.standard.synchronize()
    }
    
}
