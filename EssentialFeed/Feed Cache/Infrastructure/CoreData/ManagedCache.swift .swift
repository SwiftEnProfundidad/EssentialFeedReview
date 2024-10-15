//
//  ManagedCache.swift .swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 5/9/24.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }

    var localFeed: [LocalFeedImage] {
        feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}
