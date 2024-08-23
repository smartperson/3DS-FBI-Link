//
//  ViewController.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/20/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

func ifDarkMode(view:NSView)->Bool{
    let x = view.effectiveAppearance.name
    if x == .aqua {
        print(x)
    } else {
        print(x)
    }
    if #available(OSX 10.14, *) {
        return x == .darkAqua
    } else {
       return false
    }
}
      

@objc(ViewController)
class ViewController: NSViewController, ConsoleManagementDelegate, VKMLoggingDelegate {
    @IBOutlet weak var consoleManager:VKMConsoleManager?
    @IBOutlet weak var fileManager:VKMFileManager?
    @IBOutlet weak var dragView:VKMFullView?
    @IBOutlet weak var logScrollView:NSScrollView?
    
    var logView:NSTextView {
        get {
            let view = self.logScrollView?.contentView.documentView as! NSTextView
            return view
        }
    }
    
    @IBAction func addURL(_ sender: AnyObject?) {
        
    }
    
    @objc public var status = NSMutableDictionary()

    @objc func interfaceModeChanged(sender: NSNotification) {
      
    }
    override func viewDidLoad() {
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(interfaceModeChanged(sender:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)

        NSLog("Hi")
        dragView?.delegate = fileManager
        consoleManager?.delegate = self
        fileManager?.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //status = "App loaded"
        self.status.setValue(false, forKey:"running")
        self.status.setValue("Start", forKey: "actionTitle")
    }
    
    func socketsDisconnected() {
        self.logViewString("All consoles finished downloading.\n")
        self.stopServing()
    }
    
    func foundConsoleWith(consoleManagerItem: ConsoleManagerItem) {
        self.logViewString("Autodetected 3DS at \(consoleManagerItem.ipAddress), guessing port 5000.\n")
    }
    
    func connectedToConsole(_ console: ConsoleManagerItem) {
        let logString = "Connected to 3DS at \(console.ipAddress).\n"
        self.logViewString(logString)
        //logView?.scroll
    }

    func logStatus(_ status: String) {
        logViewString(status)
    }
    
    func logViewString(_ string: String) {

        logView.textStorage?.append(NSAttributedString(string: string))
        if ifDarkMode(view: logView) {
            logView.textColor = .white
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func toggleServer(sender: AnyObject) {
        if (fileManager?.webServer.isRunning)! {
            self.stopServing()
        } else { //if the server is running, we'll tell the console manager to send the file data over
            self.startServing()
        }
    }

    func stopServing() {
        self.logStatus("Shutting down.\n")
        fileManager?.stopServing()
        self.status.setValue(false, forKey:"running")
        self.status.setValue("Start", forKey: "actionTitle")
    }
    
    func startServing() {
        NSLog("Hi")
        fileManager?.startServing()
        self.logStatus("Starting up.\n")
        self.status.setValue(true, forKey:"running")
        consoleManager?.sendData(fileList: (fileManager?.dataArray)!, hostURL: (fileManager?.webServer.serverURL)!)
        self.status.setValue("Stop", forKey: "actionTitle")
    }
    
    @IBAction func resetStatus(sender: AnyObject) {
        fileManager?.dataArray.removeAll()
        fileManager?.received(files: []) //not beautiful, but triggers any needed bindings updates
        consoleManager?.dataArray.removeAll()
        consoleManager?.detectConsoles(sender: self)
        logView.textStorage?.mutableString.setString("<reset>\n")
    }
}

