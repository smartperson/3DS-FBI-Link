//
//  ViewController.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/20/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

@objc(ViewController)
class ViewController: NSViewController, ConsoleManagementDelegate {
    @IBOutlet weak var consoleManager:VKMConsoleManager?
    @IBOutlet weak var fileManager:VKMFileManager?
    @IBOutlet weak var dragView:VKMFullView?
    public var status:NSString = "Idle"

    override func viewDidLoad() {
        NSLog("Hi")
        dragView?.delegate = fileManager
        consoleManager?.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //status = "App loaded"
    }
    
    func socketsDisconnected() {
        print("All consoles finished downloading. We should shut down now")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func toggleServer(sender: AnyObject) {
        if (fileManager?.webServer.isRunning)! {
            print("Stop it") //we're going to stop everything before the 3DS finishes its downloads
            fileManager?.stopServing()
        } else { //if the server is running, we'll tell the console manager to send the file data over
            print("Start it")
            fileManager?.startServing()
            consoleManager?.sendData(fileList: (fileManager?.dataArray)!, hostURL: (fileManager?.webServer.serverURL)!)
        }
    }


}

