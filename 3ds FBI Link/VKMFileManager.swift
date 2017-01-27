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

protocol VKMLoggingDelegate {
    func logStatus(_ status:String) -> (Void)
}

@objc(VKMFileManager)
class VKMFileManager: NSObject, VKMFileDropDelegate {
    var dataArray:[VKMFileManagerItem] = [VKMFileManagerItem]()
    public var delegate: VKMLoggingDelegate?
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
            let matchPath = request?.path.removingPercentEncoding!
            self.delegate?.logStatus("Sending \(matchPath!).\n")
            var response: GCDWebServerFileResponse
            if let i = self.dataArray.index(where: { $0.clientURL?.path == matchPath }) {
                foundItem = self.dataArray[i]
//                self.delegate?.logStatus("Sending \(self.dataArray[i].fileName).\n")
                response = GCDWebServerFileResponse(file: foundItem?.path, isAttachment: true)
            } else {
                self.delegate?.logStatus("Error: Console asked for a file that was not added.\n")
                response = GCDWebServerFileResponse(statusCode: 404)
            }
            completionBlock!(response)
        }
    }
    
    func received(files: [String]) {
        self.willChangeValue(forKey: "dataArray")
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
    
    internal func received(url: URL) {
        self.willChangeValue(forKey: "dataArray")
        dataArray.append(VKMFileManagerItem(isUrl: true, path: url.absoluteString))
        self.didChangeValue(forKey: "dataArray")
    }
    
    func startServing() -> Bool {
        NSLog("Hi")
        self.webServer.start(withPort: 0, bonjourName: "3DS FBI Link")
        self.delegate?.logStatus("You can inspect the files list at \(webServer.serverURL)\n")
        return true
    }
    
    func stopServing() -> Bool {
        if self.webServer.isRunning { self.webServer.stop() }
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
        if !self.isUrl {
            do {
                let attr = try fd.attributesOfItem(atPath: path)
                fileSize = attr[FileAttributeKey.size] as! Int
            } catch {
                print(error)
            }
//            NSLog("Fmgr path \(path)")
            if #available(OSX 10.10, *) {
                let tempURL = URL(fileURLWithPath: path)
                self.fileName = tempURL.lastPathComponent
                let usedPath = "/"+tempURL.pathComponents.suffix(2).map{$0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!}.joined(separator: "/")
                self.clientURL = URL(string: usedPath);

            } else { //URL isn't really available on 10.11 and earlier. Can we hack something together?
//                let tempURL = NSURL(fileURLWithPath: path)
//                NSLog("FMgr tempURL \(tempURL)")
//                NSLog("FMgr tempURL absString \(tempURL.absoluteString)")
//                NSLog("FMgr tempURL relString \(tempURL.relativeString)")
//                NSLog("FMgr tempURL absPath \(tempURL.absoluteURL?.absoluteString)")
//                NSLog("FMgr tempURL relPath \(tempURL.relativePath)")
//                self.fileName = (tempURL.lastPathComponent)!
//                let pathComponents = (tempURL.pathComponents)!
//                NSLog("Fmgr pathComponents \(pathComponents)")
//                let clientURLString = "/\(pathComponents[pathComponents.count-1])"
//                NSLog("Fmgr clientURLString %@", clientURLString)
//                let clientNSURL = NSURL(string: clientURLString, relativeTo: NSURL(string: "file://") as URL?)
//                NSLog("Fmgr Client NSURL \(clientNSURL)")
//                self.clientURL = (clientNSURL as! URL)
//                NSLog("FMgr clientURL \(self.clientURL)")
            }
            self.path = path
            self.size = fileSize
        } else { //if it's a URL
            self.fileName = (URL(string: path)?.lastPathComponent)!
            self.path = path
            self.clientURL = URL(string:path)!
        }
    }
}

