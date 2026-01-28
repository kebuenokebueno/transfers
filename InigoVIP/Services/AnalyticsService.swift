//
//  AnalyticsService.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import Observation


@Observable
class AnalyticsService {
    var eventsTracked: [String] = []
    
    func track(event: String) {
        eventsTracked.append(event)
        print("📊 Analytics: \(event)")
    }
    
    func trackScreenView(_ screenName: String) {
        track(event: "screen_view: \(screenName)")
    }
    
    func trackButtonTap(_ buttonName: String) {
        track(event: "button_tap: \(buttonName)")
    }
}
