//
//  VKMTableView.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/24/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Foundation
import Cocoa

@objc(VKMTableView)
class VKMTableView: NSTableView {
    @IBOutlet weak var relatedArrayController:NSArrayController?
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }
    
    override func keyDown(with event: NSEvent) {
        let keyInput = NSString(string: event.charactersIgnoringModifiers!)
        let key = keyInput.character(at: 0) //keyInput?.substring(to: (keyInput?.index(after: (keyInput?.startIndex)!))!).characters.first
        if(Int(key) == NSDeleteCharacter) {
            if self.selectedRow == -1 {
                NSBeep()
            }
            let hasDelegate = self.window?.firstResponder.responds(to: #selector(getter: delegate))
            let isEditing = (hasDelegate! && (self.window?.firstResponder.isKind(of: NSText.self))! &&
                ((self.window?.firstResponder.perform(#selector(getter: delegate)).takeRetainedValue() as? NSObject)?.isKind(of: VKMTableView.self))! )
            if (!isEditing)
            {
                relatedArrayController?.remove(self)
                return;
            }

        }
        super.keyDown(with: event)
    }
}
