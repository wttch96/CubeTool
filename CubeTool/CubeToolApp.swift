//
//  CubeToolApp.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/21.
//

//import ApplicationServices
//qimport Cocoa
import SwiftData
import SwiftUI

@main
struct CubeToolApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        CubeInitComponent.registerComponent()
        CubeRotateComponent.registerComponent()
        PieceComponent.registerComponent()
        
        CubeInitSystem.registerSystem()
        CubeRotateSystem.registerSystem()
    }
}
