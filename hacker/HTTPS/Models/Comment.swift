//
//  Comment.swift
//  hacker
//
//  Created by yesway on 2017/1/12.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation

public class Comment: NSObject, NSCoding {

    public var type: CommentFilter?
    public var text: String?
    public var username: String?
    public var depth: Int = 0
    public var commentId: String?
    public var parentId: String?
    public var prettyTime: String?
    public var links: [NSURL]?
    public var replyURLString: String?
    public var upvoteURLAddition: String?
    public var downvoteURLAddition: String?

    public enum CommentFilter: String {
        case Default = "default"
        case Ask = "ask"
        case Jobs = "jobs"
    }
    
    internal enum serialization: String {
        case text = "text"
        case username = "username"
        case depth = "depth"
        case commentId = "commentId"
        case parentId = "parentId"
        case prettyTime = "prettyTime"
        case links = "links"
        case replyURLString = "replyURLString"
        case upvoteURLAddition = "upvoteURLAddition"
        case downvoteURLAddition = "downvoteURLAddition"
        
        static let values = [text, username, depth, commentId, parentId, prettyTime, links,
                             replyURLString, upvoteURLAddition, downvoteURLAddition]
    }
    
    public override init(){
        super.init()
    }
    
    public init(html: String, type: Post.PostFilter) {
        super.init()
        self.parseHTML(html: html, withType: type)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        for key in serialization.values {
            setValue(aDecoder.decodeObject(forKey: key.rawValue), forKey: key.rawValue)
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        for key in serialization.values {
            if let value: AnyObject = self.value(forKey: key.rawValue) as AnyObject? {
                aCoder.encode(value, forKey: key.rawValue)
            }
        }
        
    }
}
func == (larg: Comment, rarg: Comment) -> Bool {
    return larg.commentId == rarg.commentId
}

extension Comment {
    
    public typealias Response = (_ comments: [Comment]?, _ error: Fetcher.ResponseError?, _ local: Bool) -> Void
    
    public class func fetch(forPost post: Post, completion: @escaping Response) {
        let ressource = "item?id=" + post.postId!
        Fetcher.Fetch(resource: ressource,
                      parsing: {(html) in
                        var type = post.type
                        if type == nil {
                            type = Post.PostFilter.Default
                        }
                        
                        let comments = self.parseCollectionHTML(html: html, withType: type!)
                        return comments as AnyObject!
        },
                      completion: {(object, error, local) in
                        if let realObject: AnyObject = object {
                            completion(realObject as? [Comment], error, local)
                        }
                        else {
                            completion(nil, error, local)
                        }
        })
    }
}

extension Comment {
   
    class func parseCollectionHTML(html: String, withType type: Post.PostFilter) -> [Comment] {
        var components = html.components(separatedBy: "<tr><td class='ind'><img src=\"s.gif\"")
        var comments: [Comment] = []
        if (components.count > 0) {
            if (type == Post.PostFilter.Ask) {
                let scanner = Scanner(string: components[0])
                let comment = Comment()
                comment.type = CommentFilter.Ask
                comment.commentId = scanner.scanTag(startTag: "<span id=\"score_", endTag: ">")
                comment.username = scanner.scanTag(startTag: "by <a href=\"user?id=", endTag: "\">")
                comment.prettyTime = scanner.scanTag(startTag: "</a> ", endTag: "ago") + "ago"
                comment.text = String.stringByRemovingHTMLEntities(string: scanner.scanTag(startTag: "</tr><tr><td></td><td>", endTag: "</td>"))
                comment.depth = 0
                comments.append(comment)
            }
                
            else if (type == Post.PostFilter.Jobs) {
                let scanner = Scanner(string: components[0])
                let comment = Comment()
                comment.depth = 0
                comment.text = String.stringByRemovingHTMLEntities(string: scanner.scanTag(startTag: "</tr><tr><td></td><td>", endTag: "</td>"))
                comment.type = CommentFilter.Jobs
                comments.append(comment)
            }
            
            var index = 0
            
            for component in components {
                if index != 0 && index != components.count - 1 {
                    comments.append(Comment(html: component, type: type))
                }
                index += 1
            }
        }
        return comments
    }
    
    
    internal func parseHTML(html: String, withType type: Post.PostFilter) {
        let scanner = Scanner(string: html)
        
        let level = scanner.scanTag(startTag: "height=\"1\" width=\"", endTag: ">")
        
        if let unwrappedLevel = Int(level.substring(to: level.index(level.startIndex, offsetBy: level.characters.count - 1))) {
            self.depth = unwrappedLevel / 40
        } else {
            self.depth = 0
        }
        
        let username = scanner.scanTag(startTag: "<a href=\"user?id=", endTag: "\">")
        self.username = username.utf16.count > 0 ? username : "[deleted]"
        self.commentId = scanner.scanTag(startTag: "<a href=\"item?id=", endTag: "\">")
        self.prettyTime = scanner.scanTag(startTag: ">", endTag: "</a>")
        
        
        if (html.contains("[deleted]")) {
            self.text = "[deleted]"
        } else {
            let textTemp = scanner.scanTag(startTag: "<font color=", endTag: "</font>") as String
            if (textTemp.characters.count>0) {
                self.text = String.stringByRemovingHTMLEntities(string: textTemp.substring(from: textTemp.index(textTemp.startIndex, offsetBy: 10)))
            }
            else {
                self.text = ""
            }
        }
        
        //LOL, it whould always work, as I strip a Hex color, which is always the same length
        
        self.replyURLString = scanner.scanTag(startTag: "<font size=1><u><a href=\"", endTag: "\">reply")
        self.type = CommentFilter.Default
    }

    
}

















