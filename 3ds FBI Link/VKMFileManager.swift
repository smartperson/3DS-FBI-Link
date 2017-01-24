//
//  FileManager.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/20/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Foundation
import Cocoa
import GCDWebServer

@objc(VKMFileManager)
class VKMFileManager: NSObject, VKMFileDropDelegate {
    var dataArray:[VKMFileManagerItem] = [VKMFileManagerItem]()
    public var webServer: GCDWebServer = GCDWebServer()
    override init() {
        //Set up our web server paths. They will automatically handle changes in the file list later.
        super.init()
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self) {
            (request, completionBlock) in
            var responseHTML = "<html><body><p><table cellspacing=\"2\" cellpadding=\"0\"><tr><th>File</th><th>Size</th></tr>"
            for fileItem in self.dataArray {
                responseHTML.append("<tr><td><a href=\"\(fileItem.clientURL!.path)\">\(fileItem.fileName)</a></td><td>\(fileItem.size)</td></tr>")
            }
            responseHTML.append("</table></p></body></html>")
            let response = GCDWebServerDataResponse(html:responseHTML)
            completionBlock!(response)
        }
        webServer.addHandler(forMethod: "GET", pathRegex: "/(.)+", request: GCDWebServerRequest.self) {
            (request, completionBlock) in
            var foundItem:VKMFileManagerItem?
            let matchPath = request?.path
            var response: GCDWebServerFileResponse
            if let i = self.dataArray.index(where: { $0.clientURL?.path == matchPath }) {
                foundItem = self.dataArray[i]
                print("\(self.dataArray[i].path) is a match!")
                response = GCDWebServerFileResponse(file: foundItem?.path, isAttachment: true)
            } else {
                response = GCDWebServerFileResponse(statusCode: 404)
            }
            completionBlock!(response)
        }
    }
    
    func received(files: [String]) {
        self.willChangeValue(forKey: "dataArray")
        print("got files \(files)")
        let fd = FileManager.default
        var newFiles = [String]()
        for file in files {
            //first expand directories deep and add any relevant files
            var isDir: ObjCBool = false
            fd.fileExists(atPath: file, isDirectory: &isDir)
            if isDir.boolValue {
                let baseURL = URL(fileURLWithPath: file)
                for subFile in fd.enumerator(atPath: file)! {
                    var subFileURL:URL
                    if #available(OSX 10.11, *) {
                        subFileURL = URL(fileURLWithPath: subFile as! String, relativeTo: baseURL)
                    } else {
                        subFileURL = URL(string: subFile as! String, relativeTo: baseURL)!
                    }
                    if (subFileURL.pathExtension == "cia" || subFileURL.pathExtension == "tik") {
                        newFiles.append(subFileURL.path)
                    }
                }
            } else {
                newFiles.append(file)
            }
        }
        //Now process all the non-directory files. This list should not have any directories in it.
        for file in newFiles {
            print(file)
            dataArray.append(VKMFileManagerItem(isUrl: false, path: file))
        }
        self.didChangeValue(forKey: "dataArray")
    }
    
    func startServing() -> Bool {
        self.willChangeValue(forKey: "webServer")
        self.webServer.start(withPort: 0, bonjourName: "3DS FBI Link")
        self.didChangeValue(forKey: "webServer")
        return true
    }
    
    func stopServing() -> Bool {
        self.willChangeValue(forKey: "webServer")
        self.webServer.stop()
        self.didChangeValue(forKey: "webServer")
        return true
    }
}

@objc(VKMFileManagerItem)
class VKMFileManagerItem : NSObject {
    public var isUrl:Bool = false
    public var fileName:String = ""
    public var path:String = ""
    public var size:Int = 0
    public var clientURL = URL(string: "/")
    
    init(isUrl:Bool, path:String) {
        let fd = FileManager.default
        self.isUrl = isUrl
        var fileSize = 0
        do {
            let attr = try fd.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! Int
        } catch {
            print(error)
        }
        let tempURL = URL(fileURLWithPath: path)
        self.fileName = tempURL.lastPathComponent
        self.path = path
        self.size = fileSize
        self.clientURL = URL(string: "/\(tempURL.pathComponents.suffix(2).joined(separator: "/"))");
    }
}

