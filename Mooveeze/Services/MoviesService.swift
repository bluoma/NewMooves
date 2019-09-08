//
//  MoviesHttpClient.swift
//  Mooveeze
//
//  Created by Bill on 9/6/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

enum MovieListType: Int {
    
    case nowPlaying
    case topRated
}

class MoviesService {
    
    let jsonService = JsonHttpService()
    
    func fetchMovieList(withType listType: MovieListType, page: Int, completion: @escaping ((MovieResults?, NSError?) -> Void)) {
        
        var urlString = ""
        
        switch listType {
            
        case .nowPlaying:
            let nowPlayingUrlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbNowPlayingPath + "?" + Constants.theMovieDbApiKeyParam + "&page=" + String(page)
            urlString = nowPlayingUrlString
            
        case .topRated:
            let topRatedUrlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbTopRatedPath + "?" + Constants.theMovieDbApiKeyParam + "&page=" + String(page)
            urlString = topRatedUrlString
        }
        
        guard let url = URL(string: urlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(urlString)")
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
                    results.movies.forEach { $0.populateGenres() }
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
    
    func fetchMovieDetail(byId movieId: Int, completion: @escaping ((MovieDetail?, NSError?) -> Void)) {
        
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
    
    func fetchMovieVideos(byId movieId: Int, completion: @escaping (([MovieVideo], NSError?) -> Void)) {
        
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
