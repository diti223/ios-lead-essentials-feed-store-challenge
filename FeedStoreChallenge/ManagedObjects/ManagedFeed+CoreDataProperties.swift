//
//  ManagedFeed+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Adrian Bilescu on 6/22/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

extension ManagedFeed {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
		return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
	}

	@NSManaged public var timestamp: Date?
	@NSManaged public var items: NSOrderedSet?
}

// MARK: Generated accessors for items
extension ManagedFeed {
	@objc(insertObject:inItemsAtIndex:)
	@NSManaged public func insertIntoItems(_ value: ManagedFeedImage, at idx: Int)

	@objc(removeObjectFromItemsAtIndex:)
	@NSManaged public func removeFromItems(at idx: Int)

	@objc(insertItems:atIndexes:)
	@NSManaged public func insertIntoItems(_ values: [ManagedFeedImage], at indexes: NSIndexSet)

	@objc(removeItemsAtIndexes:)
	@NSManaged public func removeFromItems(at indexes: NSIndexSet)

	@objc(replaceObjectInItemsAtIndex:withObject:)
	@NSManaged public func replaceItems(at idx: Int, with value: ManagedFeedImage)

	@objc(replaceItemsAtIndexes:withItems:)
	@NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [ManagedFeedImage])

	@objc(addItemsObject:)
	@NSManaged public func addToItems(_ value: ManagedFeedImage)

	@objc(removeItemsObject:)
	@NSManaged public func removeFromItems(_ value: ManagedFeedImage)

	@objc(addItems:)
	@NSManaged public func addToItems(_ values: NSOrderedSet)

	@objc(removeItems:)
	@NSManaged public func removeFromItems(_ values: NSOrderedSet)
}

extension ManagedFeed: Identifiable {}
