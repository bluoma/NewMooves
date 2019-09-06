//
//  MoviesLoginViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, JsonDownloaderDelegate {

    enum DownloadType: String
    {
        case authToken = "authToken"
        case validateToken = "validateToken"
        case session = "session"
    }
    
    var downloadIsInProgress: Bool = false
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String: URLSessionDataTask] = [:]
    var authTokenEndpointPath: String = theMovieDbAuthTokenPath
    var validationEndpointPath: String = theMovieDbAuthTokenValidationPath
    var sessionEndpointPath: String = theMovieDbNewSessionPath

    var authToken: String = ""
    var validatedAuthToken: String = ""
    var username: String = "bluoma"
    var password: String = "max88max"
    
    var loginDidSucceed: ((String) -> Void)?
    var loginDidErr: ((NSError?) -> Void)?
    var loginDidCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonDownloader.delegate = self
        doAuthTokenDownload()
    }
    

    func doAuthTokenDownload() {
        
        if downloadIsInProgress { return }
        
        let urlString = theMovieDbSecureBaseUrl + authTokenEndpointPath + "?" + theMovieDbApiKeyParam
        cancelJsonDownloadTask(urlString: urlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: urlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task.taskDescription = DownloadType.authToken.rawValue
            downloadTaskDict[urlString] = task
        }
        else {
            self.loginDidErr?(nil)
        }
    }
    
    func doAuthTokenValidationDownload() {
        
        if downloadIsInProgress { return }
        //post
        let urlString = theMovieDbSecureBaseUrl + validationEndpointPath + "?" + theMovieDbApiKeyParam
        /*
         {
         "username": "johnny_appleseed",
         "password": "test123",
         "request_token": "1531f1a558c8357ce8990cf887ff196e8f5402ec"
         }
         */
        
        var postDict: [String: AnyObject] = [:]
        postDict["username"] = username as AnyObject
        postDict["password"] = password as AnyObject
        postDict["request_token"] = authToken as AnyObject
        
        cancelJsonDownloadTask(urlString: urlString)
        if let task: URLSessionDataTask = jsonDownloader.doPost(urlString: urlString, postBody: postDict) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task.taskDescription = DownloadType.validateToken.rawValue
            downloadTaskDict[urlString] = task
        }
        else {
            self.loginDidErr?(nil)
        }
        
    }
    
    func doSessionDownload() {
        
        if downloadIsInProgress { return }
        //post
        let urlString = theMovieDbSecureBaseUrl + sessionEndpointPath + "?" + theMovieDbApiKeyParam
        /*
         {
         "request_token": "6bc047b88f669d1fb86574f06381005d93d3517a"
         }
        */
        var postDict: [String: AnyObject] = [:]
        postDict["request_token"] = authToken as AnyObject
        cancelJsonDownloadTask(urlString: urlString)
        if let task: URLSessionDataTask = jsonDownloader.doPost(urlString: urlString, postBody: postDict) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task.taskDescription = DownloadType.session.rawValue
            downloadTaskDict[urlString] = task
        }
        else {
            self.loginDidErr?(nil)
        }
        
    }
    
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String: AnyObject]?, response: HTTPURLResponse, error: NSError?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard let urlString = response.url?.absoluteString,
            let task = downloadTaskDict[urlString] else {
                dlog("no url/task from response: \(response)")
                return
        }
        downloadTaskDict[urlString] = nil
        dlog("url from response: \(urlString)")
        
        
        if error != nil {
            dlog("err: \(String(describing: error))")
            self.loginDidErr?(error)
        }
        else {
            
            if let jsonObj: [String:AnyObject] = json,
                let taskDescription = task.taskDescription,
                let downloadType = DownloadType(rawValue: taskDescription) {
                dlog("jsonObj: \(type(of:jsonObj)), type: \(downloadType) \n\(jsonObj)")
                
                switch downloadType
                {
                case .authToken:
                    
                    if let authToken = jsonObj["request_token"] as? String {
                        dlog("authToken: \(authToken)")
                        self.authToken = authToken
                        doAuthTokenValidationDownload()
                    }
                    else {
                        self.loginDidErr?(nil)
                    }
                    
                case .validateToken:
                    
                    if let validToken = jsonObj["request_token"] as? String {
                        dlog("authToken: \(validToken)")
                        self.validatedAuthToken = validToken
                        doSessionDownload()
                    }
                    else {
                        self.loginDidErr?(nil)
                    }
                    
                case .session:
                    if let sessionId = jsonObj["session_id"] as? String {
                        dlog("sessionId: \(sessionId)")
                        self.loginDidSucceed?(sessionId)
                    }
                    else {
                        self.loginDidErr?(nil)
                    }
                }
            }
            else {
                self.loginDidErr?(nil)
            }
        }
    }
    
    func cancelJsonDownloadTask(urlString: String)
    {
        if let currentDowloadTask: URLSessionDataTask = downloadTaskDict[urlString] {
            currentDowloadTask.cancel()
            downloadTaskDict[urlString] = nil
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func cancelAllJsonDownloadTasks()
    {
        for (_, task) in downloadTaskDict {
            task.cancel()
        }
        downloadTaskDict.removeAll()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    @IBAction func donePressed(_ sender: UIBarButtonItem){
        dlog("")
        self.loginDidCancel?()
    }
}
