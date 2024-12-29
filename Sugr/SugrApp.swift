//
//  SugrApp.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import SwiftUI
import SwiftData


@main
struct SugrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appDelegate.model)
        }
    }
}
