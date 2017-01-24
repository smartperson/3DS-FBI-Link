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
        Swift.print("Awaking view from coder")
        register(forDraggedTypes: [NSFilenamesPboardType])

    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("Dragging entered")
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
        Swift.print("prepare for drag")
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // ... perform your magic
        // return true/false depending on success
        Swift.print("perform drag")
        let pasteboard = sender.draggingPasteboard()
        if ( pasteboard.types?.contains(NSFilenamesPboardType) )! {
            delegate?.received(files: pasteboard.propertyList(forType: NSFilenamesPboardType) as! [String])
        }
        return true
    }
}
