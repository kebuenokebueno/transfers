//
//  Router.swift
//  Transfers
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
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func present(sheet route: Route) {
        presentedSheet = route
    }
    
    func dismiss() {
        presentedSheet = nil
    }
}
