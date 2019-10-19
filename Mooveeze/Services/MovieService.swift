//
//  MoviesHttpClient.swift
//  Mooveeze
//
//  Created by Bill on 9/6/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class MovieService {
    
    let jsonService = JsonHttpService()
    let movieDbHttpClient: MovieDbClient = MovieDbClient()

    func fetchMovieListBis(withType listType: MovieListType, page: Int, completion: @escaping ((MovieResults?, Error?) -> Void)) {
        
        let remoteRequest = MovieRequest.fetchMovieListRequest(withType: listType, page: page)
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
                    let results: MovieResults = try decoder.decode(MovieResults.self, from: foundData)
                    results.movies.forEach { $0.populateGenres() }
                    completion(results, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                let results = MovieResults(totalResults: 0, totalPages: 0, page: 0, movies: [])
                completion(results, nil)
            }
        }
        remoteRequest.failureBlock = { (error: Error) -> Void  in
            completion(nil, error)
        }
        remoteRequest.send()
    }
    
    func fetchMovieList(withType listType: MovieListType, page: Int, completion: @escaping ((MovieResults?, Error?) -> Void)) {
        
        let remoteRequest = MovieRequest.fetchMovieListRequest(withType: listType, page: page)
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
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
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                assert(false, "unknown error")
            }
        })
    }
    
    func fetchMovieDetail(byId movieId: Int, completion: @escaping ((MovieDetail?, Error?) -> Void)) {
        
        let remoteRequest = MovieRequest.fetchMoviewDetailRequest(withMovieId: String(movieId))
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
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
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                assert(false, "unknown error")
            }
        })
    }
    
    func fetchMovieVideos(byId movieId: Int, completion: @escaping (([MovieVideo], Error?) -> Void)) {
        
        let remoteRequest = MovieRequest.fetchMovieVideosRequest(withMovieId: String(movieId))
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion([], error)
            return
        }
        
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
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
                    let serviceError = ServiceError(error)
                    completion([], serviceError)
                }
            }
            else {
               assert(false, "unknown error")
            }
        })
    }
}
