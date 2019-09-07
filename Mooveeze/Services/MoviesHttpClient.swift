//
//  MoviesHttpClient.swift
//  Mooveeze
//
//  Created by Bill on 9/6/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class MoviesHttpClient {
    
    let jsonService = JsonHttpService()
    
    func fetchNowPlayingMovieList(params: [String: AnyObject], completion: @escaping ((MovieResults?, NSError?) -> Void)) {
        
        var page = 1
        
        if let foundPage = params["page"] as? Int {
            page = foundPage
        }
        
        let nowPlayingUrlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbNowPlayingPath + "?" + Constants.theMovieDbApiKeyParam + "&page=" + String(page)
        
        guard let url = URL(string: nowPlayingUrlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(nowPlayingUrlString)")
            completion(nil, error)
            return
        }
        
        jsonService.doGet(url: url, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion(nil, error)
            }
            else if let foundData = data {
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
                    let results: MovieResults = try decoder.decode(MovieResults.self, from: foundData)
                    dlog("results: \(results)")
                    
                    results.movies.forEach { $0.populateGenres() }
                    
                    dlog("movies: \(results.movies)")

                    completion(results, nil)
                }
                catch {
                    completion(nil, error as NSError)
                }
            }
            else {
                completion(nil, generateError(withCode: -404, msg: "no data or error"))
            }
        })
    }
    
    func fetchMovieDetail(params: [String: AnyObject], completion: @escaping ((MovieDetail?, NSError?) -> Void)) {
        
        guard let movieId = params["movieId"] as? Int else {
            let error = generateError(withCode: -400, msg: "no movieId")
            completion(nil, error)
            return
        }
        
        let baseUrl = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbMovieDetailPath + "/"
        let movieDetailUrlString = baseUrl + String(movieId) + "?" + Constants.theMovieDbApiKeyParam
        
        guard let url = URL(string: movieDetailUrlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(movieDetailUrlString)")
            completion(nil, error)
            return
        }
        
        jsonService.doGet(url: url, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion(nil, error)
            }
            else if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let detail: MovieDetail = try decoder.decode(MovieDetail.self, from: foundData)
                    dlog("detail: \(detail)")
                    completion(detail, nil)
                }
                catch {
                    completion(nil, error as NSError)
                }
            }
            else {
                completion(nil, generateError(withCode: -404, msg: "no data or error"))
            }
        })
    }
    
    func fetchMovieVideos(params: [String: AnyObject], completion: @escaping (([MovieVideo], NSError?) -> Void)) {
        
        guard let movieId = params["movieId"] as? Int else {
            let error = generateError(withCode: -400, msg: "no movieId")
            completion([], error)
            return
        }
        
        let baseUrl = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbMovieDetailPath + "/"
        let movieVideoUrlString = baseUrl + String(movieId) + Constants.theMovieDbMovieVideoPath + "?" + Constants.theMovieDbApiKeyParam
        
        guard let url = URL(string: movieVideoUrlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(movieVideoUrlString)")
            completion([], error)
            return
        }
        
        jsonService.doGet(url: url, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion([], error)
            }
            else if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let videoResuls: MovieVideoResults = try decoder.decode(MovieVideoResults.self, from: foundData)
                    
                    dlog("videos: \(videoResuls.videos)")
                    completion(videoResuls.videos, nil)
                }
                catch {
                    completion([], error as NSError)
                }
            }
            else {
                completion([], generateError(withCode: -404, msg: "no data or error"))
            }
        })
    }
}
