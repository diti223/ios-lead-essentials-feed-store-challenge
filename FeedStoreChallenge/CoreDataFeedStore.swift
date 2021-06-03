//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				let request: NSFetchRequest<ManagedFeed> = ManagedFeed.fetchRequest()
				guard let feed = try context.fetch(request).first,
				      let fetchedItems = feed.items else {
					return completion(.empty)
				}
				let items = fetchedItems.map {
					$0 as! ManagedFeedImage
				}.map { item in
					LocalFeedImage(id: item.id!, description: item.imageDescription, location: item.location, url: item.url!)
				}
				completion(.found(feed: items, timestamp: feed.timestamp!))
			} catch {
				completion(.empty)
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			let managedFeed = ManagedFeed(context: context)
			managedFeed.timestamp = timestamp
			let managedItems = feed.map { (item) -> ManagedFeedImage in
				let managedItem = ManagedFeedImage(context: context)
				managedItem.id = item.id
				managedItem.imageDescription = item.description
				managedItem.location = item.location
				managedItem.url = item.url
				return managedItem
			}
			let managedItemsSet = NSOrderedSet(array: managedItems)
			managedFeed.addToItems(managedItemsSet)
			context.insert(managedFeed)

			do {
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}

	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform {
			action(context)
		}
	}
}
