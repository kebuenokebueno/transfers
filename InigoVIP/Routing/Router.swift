//
//  Router.swift
//  InigoVIP
//
//  Created by Inigo on 2/2/26.
//

import Foundation
import SwiftUI


@MainActor
@Observable
class Router {
    var path = NavigationPath()
    var presentedSheet: Route?
    var presentedFullScreen: Route?
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet route: Route) {
        presentedSheet = route
    }
    
    func present(fullScreenCover route: Route) {
        presentedFullScreen = route
    }
    
    func dismiss() {
        presentedSheet = nil
        presentedFullScreen = nil
    }
}
