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
    
    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        let action = item.action!
        if (action == #selector(delete)) {
            if (self.selectedRow >= 0) {return true}
            else {return false}
        } else {
            return super.validateUserInterfaceItem(item)
        }
    }
    @objc func delete(_ sender: Any?) {
        relatedArrayController?.remove(self)
    }
}
