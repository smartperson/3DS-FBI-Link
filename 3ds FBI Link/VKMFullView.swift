//
//  VKMFullView.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/20/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Foundation
import Cocoa

protocol VKMFileDropDelegate {
    func received(files:[String])
    func received(url: URL)
}

class VKMFullView : NSView {
//    init() {
//        Swift.print("Awaking view init")
//        register(forDraggedTypes: [NSFilenamesPboardType])
//        // registerForDraggedTypes([kUTTypeURL as String, kUTTypeFileURL as String, kUTTypeItem as String])
//        //        registerForDraggedTypes([kUTTypeFileURL,])
//
//    }
    public var delegate: VKMFileDropDelegate? = nil
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        Swift.print("Awaking view from coder")
        register(forDraggedTypes: [NSFilenamesPboardType])

    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//        Swift.print("Dragging entered")
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        if pboard.availableType(from: [NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.generic.rawValue != 0 {
                return NSDragOperation.copy
            }
        }
        return NSDragOperation.copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // ... perform your magic
        // return true/false depending on success
//        Swift.print("perform drag")
        let pasteboard = sender.draggingPasteboard()
        if ( pasteboard.types?.contains(NSFilenamesPboardType) )! {
            delegate?.received(files: pasteboard.propertyList(forType: NSFilenamesPboardType) as! [String])
        }
        return true
    }
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        let action = item.action!
//        Swift.print("Asking if view can do \(action)")
        if (action == #selector(open) || action == #selector(addURL)) {
            return true
        } else {
            return false
        }
    }
    func open(_ sender: Any?) {
        self.addFilesAndFolders(self)
    }
    func addURL(_ sender: Any?) {
        self.addURLs(self)
    }
    
    @IBAction func addFilesAndFolders(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["cia", "tik"]
        openPanel.begin() { modalResponse in
            if (modalResponse == NSFileHandlingPanelOKButton) {
                let paths = openPanel.urls.map {$0.path}
                self.delegate?.received(files: paths)
            }
        }
    }
    
    @IBAction func addURLs(_ sender: AnyObject?) {
//        Swift.print("add urls by button")
        let inputView = NSTextField(frame: NSMakeRect(0, 0, 200, 22))
//        inputView.stringValue = "https://"
//        inputView.translatesAutoresizingMaskIntoConstraints = true
//        inputView.preferredMaxLayoutWidth = 200.0
//        inputView.bounds = NSMakeRect(0, 0, 200, 25)
//        inputView.addConstraint(NSLayoutConstraint()
//        inputView.translatesAutoresizingMaskIntoConstraints = true
        let alert = NSAlert()
        alert.accessoryView = inputView
        alert.messageText = "Enter a link to a CIA."
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")
        let button = alert.runModal()
//        Swift.print("returned button \(button)")
        if (button == NSAlertFirstButtonReturn) {
            
//            Swift.print("First button return")
            let url = URL(string: inputView.stringValue)
            if (url != nil) {
//                Swift.print("url: \(url?.absoluteString)")
                delegate?.received(url: url!)
            } else {
                
            }
        } else {
            return
        }
    }
}
