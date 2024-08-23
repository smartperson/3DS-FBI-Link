//
//  ConsoleManager.swift
//  3ds FBI Link
//
//  Created by Varun Mehta on 1/20/17.
//  Copyright © 2017 Varun Mehta. All rights reserved.
//

import Foundation
import Cocoa
import CocoaAsyncSocket

protocol ConsoleManagementDelegate {
    func socketsDisconnected() -> Void
    func foundConsoleWith(consoleManagerItem: ConsoleManagerItem) -> Void
    func connectedToConsole(_ console:ConsoleManagerItem) -> Void
}

@objc(ConsoleManagerItem)
class ConsoleManagerItem:NSObject {
    @objc public var ipAddress:String = "0.0.0.0"
    @objc public var port:UInt16 = 5000
    
    override init() {
        self.ipAddress = "0.0.0.0"
        self.port = 5000
    }
    
    init(ipAddress:String, port:UInt16) {
        self.ipAddress = ipAddress
        self.port = port
    }

}


@objc(VKMConsoleManager)
class VKMConsoleManager: NSObject, GCDAsyncSocketDelegate, NSTableViewDataSource {
    public var delegate: ConsoleManagementDelegate?
    @objc var dataArray:[ConsoleManagerItem] = [ConsoleManagerItem]()
    @objc var sockets = [GCDAsyncSocket]()
    override init() {
        super.init()
        self.performSelector(inBackground: #selector(self.detectConsoles), with: self)
    }
    
    @objc func detectConsoles(sender: Any) {
        // Create a Task instance
        let task = Process()
        
        // Set the task parameters
        task.launchPath = "/usr/sbin/arp"
        task.arguments = ["-a"]
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        let ipPattern = "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b"
        let macPattern = " ([0-9a-fA-F]{1,2}:){2}([0-9a-fA-F]{1,2})"
        let nintendoMACs = ["e8:4e:ce", "e0:e7:51", "e0:c:7f", "d8:6b:f7", "cc:fb:65", "cc:9e:0", "b8:ae:6e", "a4:c0:e1", "a4:5c:27", "9c:e6:35", "98:b6:e9", "8c:cd:e8", "8c:56:c5", "7c:bb:8a", "78:a2:a0", "58:bd:a3", "40:f4:7", "40:d2:8a", "34:af:2c", "2c:10:c1", "18:2a:7b", "0:27:9", "0:26:59", "0:25:a0", "0:24:f3", "0:24:44", "0:24:1e", "0:23:cc", "0:23:31", "0:22:d7", "0:22:aa", "0:22:4c", "0:21:bd", "0:21:47", "0:1f:c5", "0:1f:32", "0:1e:a9", "0:1e:35", "0:1d:bc", "0:1c:be", "0:1b:ea", "0:1b:7a", "0:1a:e9", "0:19:fd", "0:19:1d", "0:17:ab", "0:16:56", "0:9:bf" ]
        
        let ipMatches = matches(for: ipPattern, in: output!)
        let macMatches = matches(for: macPattern, in: output!)
//        print(ipMatches)
//        print(macMatches)
        for (index, macMatch) in macMatches.enumerated() {
            var cleanedMAC = macMatch
            cleanedMAC.remove(at: cleanedMAC.startIndex)
            if nintendoMACs.contains(cleanedMAC) {
                self.willChangeValue(forKey: "dataArray")
                dataArray.append(ConsoleManagerItem(ipAddress: ipMatches[index], port: 5000))
                self.didChangeValue(forKey: "dataArray")
            }
        }
//        print(output!)
    }

    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public func sendData(fileList: [VKMFileManagerItem], hostURL: URL) {
//        NSLog("At start of ConsoleManager sendData")
        var dataPayload = Data()
        var urlData = Data()
//        NSLog("102")
        for fileItem in fileList {
            var singleURL:URL
            if (fileItem.isUrl) {
                singleURL = (fileItem.clientURL)!
//                NSLog("singleURL \(fileItem.clientURL)")
            } else {
                let urlString = fileItem.clientURL?.absoluteString
//                NSLog("urlString \(urlString)")
//                NSLog("urlString \(fileItem.clientURL?.relativeString)")
//                NSLog("urlString \(fileItem.clientURL?.path)")
//                NSLog("urlString \(fileItem.clientURL?.relativePath)")
                let index = urlString?.index(after: (urlString?.startIndex)!)
//                print("index \(index)")
                singleURL = hostURL.appendingPathComponent((urlString?.substring(from: index!))!)
//                NSLog("singleURL \(singleURL)")
            }
            urlData.append((singleURL.absoluteString+"\n").data(using: String.Encoding.utf8)!)
//            NSLog("urlData length \(urlData.count)")
        }
        // var newData = Data(bytes: &urlDataCount, count: 4)
        var urlDataCount:UInt32 = UInt32(urlData.count).bigEndian //need to be encoded for network (big endian)
        dataPayload.append(Data(bytes: &urlDataCount, count: 4))
        dataPayload.append(urlData)
        for consoleManagerItem in dataArray {
            do {
                let socket = GCDAsyncSocket()
                socket.setDelegate(self, delegateQueue: DispatchQueue.main)
                try socket.connect(toHost: consoleManagerItem.ipAddress, onPort: consoleManagerItem.port)
                socket.write(dataPayload as Data, withTimeout: 2000, tag: 0)
                socket.readData(toLength: 1, withTimeout: -1, tag: 1)
                sockets.append(socket)
            }
            catch {
                print("Something went wrong.\n")
            }
        }
    }
    
    @objc public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        delegate?.connectedToConsole(dataArray.first { item in
            return item.ipAddress == host
        }!)
    }
    
    @objc public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if(err != nil) {
            print("Socket disconnected, error \(err)")
        } else {
            print("Socket disconnected. All done.")
        }
        var allDisconnected = true
        for socket in sockets {
            if socket.isConnected {allDisconnected = false}
        }
        if allDisconnected {delegate?.socketsDisconnected()}
    }
    
    @objc public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
//        print("Wrote data with tag \(tag)")
    }
    
    @objc public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        //getting 1 byte back from console means it's done and we should disconnect
        sock.disconnectAfterReadingAndWriting()
    }
    
}
