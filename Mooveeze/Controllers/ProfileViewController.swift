//
//  ProfileViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, JsonDownloaderDelegate {

    enum DownloadType: String
    {
        case profile = "profile"
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    var downloadIsInProgress: Bool = false
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String: URLSessionDataTask] = [:]
    var endpointPath: String = theMovieDbProfilePath
    var userProfile: UserProfile?
    
    var didSelectLogin: (() -> Void)?
    var didSelectCreateAccount: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if sessionId == nil {
            self.emptyStateView.isHidden = false
        }
        else {
            self.emptyStateView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dlog("")
        if let foundSessionId = sessionId, userProfile == nil {
            
            dlog("foundSessionId: \(foundSessionId), getAccount")

            jsonDownloader.delegate = self
            doDownload()
            
        }
    }
    

    func doDownload() {
        
        guard let foundSessionId = sessionId else { return }
        if downloadIsInProgress { return }
        
        let urlString = theMovieDbSecureBaseUrl + endpointPath + "?" + theMovieDbApiKeyParam + "&" + theMovieDbSessionKeyName + "=" + foundSessionId
        cancelJsonDownloadTask(urlString: urlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: urlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task.taskDescription = DownloadType.profile.rawValue
            downloadTaskDict[urlString] = task
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
            
        }
        else {
            
            if let jsonObj: [String:AnyObject] = json,
                let taskDescription = task.taskDescription,
                let downloadType = DownloadType(rawValue: taskDescription) {
                dlog("jsonObj: \(type(of:jsonObj)), type: \(downloadType), json: \n\(jsonObj)")
                
                switch downloadType
                {
                case .profile:
                    let userProfile = UserProfile(jsonDict: jsonObj as NSDictionary)
                    self.userProfile = userProfile
                    self.title = userProfile.username
                    self.emptyStateView.isHidden = true
                    dlog("userProfile: \(userProfile)")
                }
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
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        dlog("")
        self.didSelectLogin?()
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        dlog("")
        self.didSelectCreateAccount?()
    }
}

//https://api.themoviedb.org/3/account?api_key=d2f534caef1352faf672a1d1b1528999&ssession_id=b5e31e54cedaff28be9d617bfce2ce45927310dc
//https://api.themoviedb.org/3/account?api_key=d2f534caef1352faf672a1d1b1528999&session_id=b5e31e54cedaff28be9d617bfce2ce45927310dc
