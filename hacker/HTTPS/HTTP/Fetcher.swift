//
//  Fetcher.swift
//  hacker
//
//  Created by yesway on 2017/1/10.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

private let _Fetcher = Fetcher()

public class Fetcher {

    internal let baseURL = "https://news.ycombinator.com/"
    internal let APIURL = "https://hacker-news.firebaseio.com/v0/"
    internal let APIFormat = ".json"
    private let session = URLSession.shared
    
    public enum ResponseError: String {
        case NoConnection = "You are not connected to the internet"
        case ErrorPaesing = "An error occurred while fetching the requested page"
        case UnknownError = "An unknown error occurred"
    }
    
    public typealias FetchCompletion = (_ object: AnyObject?, _ error: ResponseError?, _ local: Bool) -> Void
    public typealias FetchParsing = (_ html: String) -> AnyObject!
    public typealias FetchParsingAPI = (_ json: AnyObject) -> AnyObject!
    
    public enum APIEndpoint: String {
        case Post = "item/"
        case User = "user/"
        case Top = "topstories"
        case New = "newstories"
        case Ask = "askstories"
        case Jobs = "jobstories"
        case Show = "showstories"
    }
    
    
    public class var sharedInstance: Fetcher {
        return _Fetcher
    }
    
    class func Fetch(resource: String, parsing: @escaping FetchParsing, completion: @escaping FetchCompletion) {
        
        let cacheKey = Cache.generateCacheKey(path: resource)
        Cache.shareCache.objectForKey(key: cacheKey) { (object: AnyObject?) in
            completion(object, nil, true)
        }
        
        
        let path = _Fetcher.baseURL + resource
        let task = _Fetcher.session.dataTask(with: URL(string: path)!) { (data, response, error) in
            DispatchQueue.main.async(execute: {
                
            if !(error != nil) {
                if let realData = data {
                    let string = String(data: realData, encoding: String.Encoding.utf8)
                    let object = parsing(string!)
                    completion(object, nil, false)
                } else {
                    completion(nil, Fetcher.ResponseError.UnknownError, false)
                }
            } else {
                completion(nil, Fetcher.ResponseError.UnknownError, false)
            }
            
            })
            
        }
                
        task.resume()
    }
    
    class func FetchJSON(endPoint: APIEndpoint, ressource: String?, parsing: @escaping FetchParsingAPI, completion: @escaping FetchCompletion) {
        var path: String
        if let realRessource: String = ressource {
            path = _Fetcher.APIURL + endPoint.rawValue + realRessource + _Fetcher.APIFormat
        } else {
            path = _Fetcher.APIURL + endPoint.rawValue + _Fetcher.APIFormat
        }
        
        let cacheKey = Cache.generateCacheKey(path: path)
        Cache.shareCache.objectForKey(key: cacheKey) { (object) in
            completion(object, nil, true)
        }
        
        let task = _Fetcher.session.dataTask(with: URL(string: path)!) { (data, response, error) in
            
            DispatchQueue.main.async(execute: {
            if let realData = data {
                var error: Error? = nil
                var JSON: AnyObject!
                
                do {
                    JSON = try? JSONSerialization.jsonObject(with: realData, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                } catch let error1 {
                    error = error1
                    JSON = nil
                } catch {
                    fatalError()
                }
                
                if error == nil {
                    let object = parsing(JSON)
                    if let object = object {
                        Cache.shareCache.setObject(object: object, key: cacheKey)
                        completion(object, nil, false)
                    }else {
                        completion(nil, Fetcher.ResponseError.ErrorPaesing, false)
                    }
                }
                
            } else {
                completion(nil, Fetcher.ResponseError.ErrorPaesing, false)
            }
            })
        }
        task.resume()
    }
}
