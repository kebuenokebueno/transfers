//
//  AnalyticsWorker.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//


protocol AnalyticsWorkerProtocol: Sendable {
    func trackEvent(_ event: String) async
    func trackScreenView(_ screenName: String) async
}


actor AnalyticsWorker: AnalyticsWorkerProtocol {
    // ✅ Worker consume Service
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    func trackEvent(_ event: String) async {
        await analyticsService.track(event: event)
    }
    
    func trackScreenView(_ screenName: String) async {
        await analyticsService.trackScreenView(screenName)
    }
}
