//
//  AppDelegate.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/20/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        print("Open file: \(filename)")
        return true
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        print("Open all the files! \(filenames)")
        (NSApplication.shared.mainWindow?.contentView as! VKMFullView).delegate!.received(files: filenames)
        return
    }
}

