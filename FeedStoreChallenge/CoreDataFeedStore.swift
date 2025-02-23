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
				guard let feed = try Self.fetchFirstManagedFeed(context) else {
					return completion(.empty)
				}
				let feedImages = feed.managedFeedImages.map(LocalFeedImage.init(managedFeedImage:))
				completion(.found(feed: feedImages, timestamp: feed.timestamp))
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in

			let managedFeed = Self.createManagedFeed(from: feed, in: context)
			managedFeed.timestamp = timestamp

			do {
				try context.execute(Self.makeDeleteManagedFeedRequest())
				try context.save()
				completion(nil)
			} catch {
				completion(error)
				context.rollback()
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try context.execute(Self.makeDeleteManagedFeedRequest())
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	//MARK: - Private Methods

	private static func makeDeleteManagedFeedRequest() -> NSBatchDeleteRequest {
		NSBatchDeleteRequest(fetchRequest: ManagedFeed.fetchRequest())
	}

	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform {
			action(context)
		}
	}

	private static func fetchFirstManagedFeed(_ context: NSManagedObjectContext) throws -> ManagedFeed? {
		let request: NSFetchRequest<ManagedFeed> = ManagedFeed.fetchRequest()
		return try context.fetch(request).first
	}

	private static func createManagedFeedImage(from feedImage: LocalFeedImage, in context: NSManagedObjectContext) -> ManagedFeedImage {
		let managedItem = ManagedFeedImage(context: context)
		managedItem.id = feedImage.id
		managedItem.imageDescription = feedImage.description
		managedItem.location = feedImage.location
		managedItem.url = feedImage.url
		return managedItem
	}

	private static func createManagedFeed(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> ManagedFeed {
		let managedFeed = ManagedFeed(context: context)
		let managedItems = feed.map { createManagedFeedImage(from: $0, in: context) }
		let managedItemsSet = NSOrderedSet(array: managedItems)
		managedFeed.addToItems(managedItemsSet)
		return managedFeed
	}
}

private extension ManagedFeed {
	var managedFeedImages: [ManagedFeedImage] {
		items.compactMap {
			$0 as? ManagedFeedImage
		}
	}
}

private extension LocalFeedImage {
	init(managedFeedImage feedImage: ManagedFeedImage) {
		self.init(id: feedImage.id, description: feedImage.imageDescription, location: feedImage.location, url: feedImage.url)
	}
}
