//
//  Post.swift
//  hacker
//
//  Created by yesway on 2017/1/12.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

public class Post: NSObject, NSCoding {
    
    public var id: Int?
    public var title: String?
    public var username: String?
    public var url: NSURL?
    public var domain: String? {
        get {
            if let realUrl = self.url {
                if let host = realUrl.host {
                    if (host.hasPrefix("www")) {
                        return host.substring(from: host.startIndex)
                    }
                    return host
                }
            }
            return ""
        }
    }
    public var points: Int = 0
    public var commentsCount: Int = 0
    public var postId: String?
    public var prettyTime: String?
    public var upvoteURL: String?
    public var type: PostFilter?
    public var kids: [Int]?
    public var score: Int?
    public var time: Int?
    public var dead: Bool = false
    
    public enum PostFilter: String {
        case Top = ""
        case Default = "default"
        case Ask = "ask"
        case New = "newest"
        case Jobs = "jobs"
        case Best = "best"
        case Show = "show"
    }
    
    internal enum serialization: String {
        case title = "title"
        case username = "username"
        case url = "url"
        case points = "points"
        case commentsCount = "commentsCount"
        case postId = "postId"
        case prettyTime = "prettyTime"
        case upvoteURL = "upvoteURL"
        
        static let values = [title, username, url, points, commentsCount, postId, prettyTime, upvoteURL]
    }
    
    internal enum JSONField: String {
        case id = "id"
        case by = "by"
        case descendants = "descendants"
        case kids = "kids"
        case score = "score"
        case time = "time"
        case title = "title"
        case type = "type"
        case url = "url"
        case dead = "dead"
    }
    
    public override init(){
        super.init()
    }
    
    public init(html: String) {
        super.init()
        self.parseHTML(html: html)
    }
    
    public init(json: NSDictionary) {
        super.init()
        self.parseJSON(json: json)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        
        for key in serialization.values {
            setValue(aDecoder.decodeObject(forKey: key.rawValue), forKey: key.rawValue)
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        for key in serialization.values {
            if let value = self.value(forKey: key.rawValue) {
                aCoder.encode(value, forKey: key.rawValue)
            }
        }
    }
    
    private func encode(object: AnyObject, key: String, coder: NSCoder) {
        coder.encode(object, forKey: key)
    }
}

func == (larg: Post, rarg: Post) -> Bool {
    return larg.postId == rarg.postId
}
extension Post {
    
    public typealias Response = (_ posts: [Post]?, _ error: Fetcher.ResponseError?, _ local: Bool) -> Void
    public typealias ResponsePost = (_ posts: Post?, _ error: Fetcher.ResponseError?, _ local: Bool) -> Void
    public typealias ResponsePosts = (_ posts: [Int]?, _ error: Fetcher.ResponseError?, _ local: Bool) -> Void
    
    public class func fetch(_ filter: PostFilter, withPage page: Int, and completion: @escaping Response) {
        Fetcher.Fetch(resource: filter.rawValue + "?p=\(page)", parsing: { (html) -> AnyObject! in
            if html != nil {
                let posts = self.parseCollectionHTML(html: html)
                return posts as AnyObject!
            } else {
                return nil
            }
        }) { (object, error, local) in
            if let realObject = object {
                completion(realObject as? [Post], error, local)
            } else {
                completion(nil, error, local)
            }
        }
    }
    
    public class func fetch(filter: PostFilter, completion: @escaping Response) {
        fetch(filter, withPage: 1, and: completion)
    }
    
    public class func fetch(user: String, page: Int, lastPostId:String?, completion: @escaping Response) {
        var additionalParameters = ""
        if let lastPostIdInt = Int(lastPostId ?? "") {
            additionalParameters = "&next=\(lastPostIdInt-1)"
        }
        Fetcher.Fetch(resource: "submitted?id=" + user + additionalParameters, parsing: { (html) -> AnyObject! in
            let posts = self.parseCollectionHTML(html: html)
            return posts as AnyObject!
        }) { (object, error, local) in
            if let realObject: AnyObject = object {
                completion(realObject as? [Post], error, local)
            }
            else {
                completion(nil, error, local)
            }
            
        }
    }
    
    public class func fetch(user: String, completion: @escaping Response) {
        fetch(user: user, page: 1, lastPostId:nil, completion: completion)
    }
    
    public class func fetchPost(completion: @escaping ResponsePosts) {
        Fetcher.FetchJSON(endPoint: .Top, ressource: nil, parsing: { (json) -> AnyObject! in
            if let _ = json as? [Int] {
                return json
            }
            return nil
        }) { (object, error, local) -> Void in
            completion(object as? [Int] , error, local)
        }
    }
    
    public class func fetchPost(post: Int, completion: @escaping ResponsePost) {
        Fetcher.FetchJSON(endPoint: .Post, ressource: String(post), parsing: { (json) -> AnyObject! in
            if let dic = json as? NSDictionary {
                return Post(json: dic)
            }
            return nil
        })
        { (object, error, local) -> Void in
            completion(object as? Post, error, local)
        }
    }
    
}
internal extension Post {
    
    func parseJSON(json: NSDictionary) {
        self.id = json[JSONField.id.rawValue] as? Int
        if let kids = json[JSONField.kids.rawValue] as? [Int] {
            self.kids = kids
        }
        self.title = json[JSONField.title.rawValue] as? String
        self.score = json[JSONField.score.rawValue] as? Int
        self.username = json[JSONField.by.rawValue] as? String
        self.time = json[JSONField.time.rawValue] as? Int
        self.url = NSURL(string: (json[JSONField.url.rawValue] as? String)!)
        if let commentsCount = json[JSONField.descendants.rawValue] as? Int {
            self.commentsCount = commentsCount
        }
        if let _ = json[JSONField.dead.rawValue] as? Bool {
            self.dead = true
        }
    }
    
    internal func parseHTML(html: String) {
        let scanner = Scanner(string: html)

        if (html.range(of: "<td class=\"title\"> [dead] <a") == nil) {
            
            self.url = NSURL(string: scanner.scanTag(startTag: "<a href=\"", endTag: "\""))
            self.title = scanner.scanTag(startTag: ">", endTag: "</a>")
            
            var temp: NSString = scanner.scanTag(startTag: "<span class=\"score\" id=\"score_", endTag: "</span>") as NSString
            let range = temp.range(of: ">")
            if (range.location != NSNotFound) {
                let tmpPoint = Int(temp.substring(from: range.location + 1).replacingOccurrences(of: "points", with: "", options: String.CompareOptions.caseInsensitive, range: nil))
                if let points = tmpPoint {
                    self.points = points
                }
                else {
                    self.points = 0
                }
            }
            else {
                self.points = 0
            }
            self.username = scanner.scanTag(startTag: "<a href=\"user?id=", endTag: "\"")
            if self.username == nil {
                self.username = "HN"
            }
            self.postId = scanner.scanTag(startTag: "<a href=\"item?id=", endTag: "\">")
            self.prettyTime = scanner.scanTag(startTag: ">", endTag: "</a>")
            
            temp = scanner.scanTag(startTag: "\">", endTag: "</a>") as NSString
            if (temp == "discuss") {
                self.commentsCount = 0
            }
            else {
                self.commentsCount = temp.integerValue
            }
            if (self.username == nil && self.commentsCount == 0 && self.postId == nil) {
                self.type = PostFilter.Jobs
                self.username = "Jobs"
            }
            else if (self.url?.absoluteString?.localizedCaseInsensitiveCompare("http") == nil) {
                self.type = PostFilter.Ask
                if let realURL = self.url {
                    let url = realURL.absoluteString
                    self.url = NSURL(string: "https://news.ycombinator.com/" + url!)
                }
            }
            else {
                self.type = PostFilter.Default
            }
        }
    }
    
    internal class func parseCollectionHTML(html: String) -> [Post] {
        let components = html.components(separatedBy: "<td align=\"right\" valign=\"top\" class=\"title\">")
        var posts: [Post] = []
        if (components.count > 0) {
            var index = 0
            for component in components {
                if index != 0 {
                    posts.append(Post(html: component))
                }
                index += 1
            }
        }
        return posts
    }

}













