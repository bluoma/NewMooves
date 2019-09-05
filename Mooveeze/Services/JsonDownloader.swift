//
//  JsonDownloader.swift
//  Mooveeze
//
//  Created by Bill on 10/3/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import Foundation

protocol JsonDownloaderDelegate: class {
    
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String:AnyObject]?, response: HTTPURLResponse, error: NSError?)
    
}

typealias JsonDownloadCompletionHandler = ([String:AnyObject]?, HTTPURLResponse?, NSError?) -> Void

class JsonDownloader {
    
    var session: URLSession! = nil
    weak var delegate: JsonDownloaderDelegate? = nil
    
    init() {
        
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 12
        urlconfig.timeoutIntervalForResource = 12
        //urlconfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
    }
    
    func doDownload(
        urlString: String,
        completion: @escaping JsonDownloadCompletionHandler) -> URLSessionDataTask? {
    
        guard let url = URL(string: urlString) else {
            dlog("bad url: \(urlString)")
            return nil
        }
        
        dlog("in url: \(urlString)")
        
        let dataTask = session.dataTask(with: url, completionHandler:
        { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            var returnedError: NSError? = nil
            var json: [String: AnyObject]? = nil
            var statusCode: Int = 0;
            var contentType: String = ""
            var httpResp: HTTPURLResponse? = nil
            
            defer {
                DispatchQueue.main.async {
                    completion(json, httpResp, returnedError)
                }
            }
            
            guard let localResp = response as? HTTPURLResponse else {
                let err: NSError = NSError(domain: "mooveeze", code: -2, userInfo: nil)
                returnedError = err
                return
            }
            
            //for the defer block above
            httpResp = localResp
                
            if let conType = localResp.allHeaderFields["Content-Type"] as? String {
                contentType = conType
            }
            statusCode = localResp.statusCode
            dlog("responseUrl: \(String(describing: localResp.url))")
            dlog("responseCode: \(statusCode)")
            
            if let foundError = error {
                dlog("error: \(foundError)")
                returnedError = foundError as NSError
            }
            else if let foundData = data {
                if (contentType.contains("json")) {
                    do {
                        // Convert NSData to Dictionary where keys are of type String, and values are of any type
                        json = try JSONSerialization.jsonObject(with: foundData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
                        
                    }
                    catch let jerr as NSError {
                        dlog("json Error: \(jerr)")
                        returnedError = jerr
                    }
                }
                else {
                    let errString = "contentType is not json: \(contentType)"
                    dlog(errString)
                    let err: NSError = NSError(domain: "mooveeze", code: -400, userInfo: nil)
                    returnedError = err
                }
            }
            else {
                dlog("both data and error are nil")
                let err: NSError = NSError(domain: "mooveeze", code: -100, userInfo: nil)
                returnedError = err
            }
        })
        
        return dataTask
    }
    
    
    func doDownload(urlString: String) -> URLSessionDataTask? {
        
        guard let url = URL(string: urlString) else {
            dlog("bad url: \(urlString)")
            return nil
        }
        
        dlog("in url: \(urlString)")

        
        let dataTask = session.dataTask(with: url, completionHandler:
        { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            var returnedError: NSError? = nil
            var json: [String:AnyObject]? = nil
            var statusCode: Int = 0;
            var contentType: String = ""
            var httpResp: HTTPURLResponse! = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "1.1", headerFields: nil)
            
            
            if response != nil {
                
                httpResp = response as? HTTPURLResponse
              
                
                if (httpResp.allHeaderFields["Content-Type"] != nil) {
                    contentType = httpResp.allHeaderFields["Content-Type"] as! String
                }
                statusCode = httpResp.statusCode
                dlog("responseUrl: \(String(describing: httpResp.url))")
                dlog("responseCode: \(statusCode)")
                
                /*
                for (hkey, hval) in httpResp.allHeaderFields {
                    
                    let skey: String = hkey as! String
                    let sval: String = hval as! String

                    dlog("header: \(skey)::\(sval)")
                }
                */
            }
            
            if error != nil {
                dlog("error: \(String(describing: error))")
                returnedError = error as NSError?
            }
            else if data != nil {
                if (contentType.contains("json")) {
                    do {
                        // Convert NSData to Dictionary where keys are of type String, and values are of any type
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
                        
                    }
                    catch let jerr as NSError {
                        dlog("json Error: \(jerr)")
                        returnedError = jerr
                    }
                }
                else {
                    let errString = "contentType is not json: \(contentType)"
                    dlog(errString)
                    let err: NSError = NSError(domain: "mooveeze", code: -400, userInfo: nil)
                    returnedError = err
                }
            }
            else {
                dlog("both data and error are nil")
                returnedError = nil
            }
            
            DispatchQueue.main.async {
                self.delegate?.jsonDownloaderDidFinish(downloader: self, json: json, response: httpResp, error: returnedError)
            }
            
        })
        
        dataTask.resume()
        
        return dataTask
        
    }
    
    
}
