//
//  Cache.swift
//  hacker
//
//  Created by yesway on 2017/1/10.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation

private let _Cache = Cache()
private let _MemoryCache = MemoryCache()
private let _DiskCache = DiskCache()

public typealias cacheCompletion = (AnyObject?) -> Void

public class Cache {

    public class var shareCache: Cache {
        return _Cache
    }
    
    init() {}
    
    public class func generateCacheKey(path: String) -> String {
        if (path == "") {
            return "root"
        }
        return path.replacingOccurrences(of: "/", with: "#", options: String.CompareOptions.caseInsensitive, range: nil)
    }
    
    public func setObject(object: AnyObject, key: String) {
        if (object.conforms(to: NSCoding.self)) {
            MemoryCache.shareMemoryCache.setObject(object: object, key: key)
            DiskCache.shareDiskCache.setObject(object: object, key: key)
        }
    }
    
    public func objectForKey(key: String, completion: @escaping cacheCompletion) {
        MemoryCache.shareMemoryCache.objectForKey(key: key) { (object) in
            if let realObject = object {
                completion(realObject)
            } else {
                DiskCache.shareDiskCache.objectForKey(key: key, completion: { (object) in
                    completion(object)
                })
            }
        }
    }
    
    public func objectForKeySync(key: String) -> AnyObject? {
        let ramObject = MemoryCache.shareMemoryCache.objectForKeySync(key: key)
        return (ramObject != nil) ? ramObject : DiskCache.shareDiskCache.objectForKeySync(key: key)
    }
    
    public func removeObject(key: String) {
        MemoryCache.shareMemoryCache.removeObject(key: key)
        DiskCache.shareDiskCache.removeObject(key: key)
    }
    
    public func removeAllObject() {
        MemoryCache.shareMemoryCache.removeAllObject()
        DiskCache.shareDiskCache.removeAllObject()
    }
}
public class DiskCache: Cache {
    
    private struct files {
        static var filePath: String {
            let manager = FileManager.default
            var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let cachePath = paths[0] + "/modelCache/"
            
            if !manager.fileExists(atPath: cachePath) {
                do {
                    try manager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    print(error)
                }
            }
            
            return cachePath
        }
    }
    private let priority = DispatchQueue.GlobalQueuePriority.default
    
    public class var shareDiskCache: Cache {
        return _DiskCache
    }
    
    override init() {
        
    }
    
    public func fullPath(key: String) -> String {
        return files.filePath + key
    }
    
    public func objectExist(key: String) -> Bool {
        return FileManager.default.fileExists(atPath: fullPath(key: key))
    }
    
    public override func objectForKey(key: String, completion: @escaping cacheCompletion) {
        if (self.objectExist(key: key)) {
            DispatchQueue.global().async(execute: { 
               let object = NSKeyedUnarchiver.unarchiveObject(withFile: self.fullPath(key: key)) as AnyObject
                DispatchQueue.main.async(execute: { 
                    completion(object)
                })
            })
        } else {
            completion(nil)
        }
    }
    
    public override func objectForKeySync(key: String) -> AnyObject? {
        if self.objectExist(key: key) {
            return NSKeyedUnarchiver.unarchiveObject(withFile: self.fullPath(key: key)) as AnyObject?
        }
        return nil
    }
    
    public override func setObject(object: AnyObject, key: String) {
        NSKeyedArchiver.archiveRootObject(object, toFile: self.fullPath(key: key))
    }
    
    public override func removeObject(key: String) {
        if self.objectExist(key: key) {
            do {
                try FileManager.default.removeItem(atPath: self.fullPath(key: key))
            } catch let error {
                print(error)
            }
        }
    }
    
    public override func removeAllObject() {
        
    }
}

public class MemoryCache: Cache {
    private var memoryCache = NSCache<AnyObject, AnyObject>()
    
    public class var shareMemoryCache: Cache {
        return _MemoryCache
    }
    
    override init() {
        
    }
    
    public override func objectForKeySync(key: String) -> AnyObject? {
        return self.memoryCache.object(forKey: key as AnyObject)
    }
    
    public override func objectForKey(key: String, completion: @escaping cacheCompletion) {
        completion(self.memoryCache.object(forKey: key as AnyObject))
    }
    
    public override func setObject(object: AnyObject, key: String) {
        self.memoryCache.setObject(object, forKey: key as AnyObject)
    }
    
    public override func removeObject(key: String) {
        self.memoryCache.removeObject(forKey: key as AnyObject)
    }
    
    public override func removeAllObject() {
        self.memoryCache.removeAllObjects()
    }
}














