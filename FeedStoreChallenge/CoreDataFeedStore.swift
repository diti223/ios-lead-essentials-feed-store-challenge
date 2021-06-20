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
				guard let feed = try self.fetchFirstManagedFeed(),
				      let managedFeedImages = feed.managedFeedImages else {
					return completion(.empty)
				}
				let feedImages = managedFeedImages.compactMap(LocalFeedImage.init(managedFeedImage:))
				completion(.found(feed: feedImages, timestamp: feed.timestamp!))
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in

			let managedFeed = self.createManagedFeed(from: feed)
			managedFeed.timestamp = timestamp

			do {
				try context.execute(self.makeDeleteManagedFeedRequest())
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
				try context.execute(self.makeDeleteManagedFeedRequest())
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	//MARK: - Private Methods

	private func makeDeleteManagedFeedRequest() -> NSBatchDeleteRequest {
		NSBatchDeleteRequest(fetchRequest: ManagedFeed.fetchRequest())
	}

	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform {
			action(context)
		}
	}

	private func fetchFirstManagedFeed() throws -> ManagedFeed? {
		let request: NSFetchRequest<ManagedFeed> = ManagedFeed.fetchRequest()
		return try context.fetch(request).first
	}

	private func createManagedFeedImage(from feedImage: LocalFeedImage) -> ManagedFeedImage {
		let managedItem = ManagedFeedImage(context: context)
		managedItem.id = feedImage.id
		managedItem.imageDescription = feedImage.description
		managedItem.location = feedImage.location
		managedItem.url = feedImage.url
		return managedItem
	}

	private func createManagedFeed(from feed: [LocalFeedImage]) -> ManagedFeed {
		let managedFeed = ManagedFeed(context: context)
		let managedItems = feed.map(createManagedFeedImage(from:))
		let managedItemsSet = NSOrderedSet(array: managedItems)
		managedFeed.addToItems(managedItemsSet)
		return managedFeed
	}
}

private extension ManagedFeed {
	var managedFeedImages: [ManagedFeedImage]? {
		items?.map {
			$0 as! ManagedFeedImage
		}
	}
}

private extension LocalFeedImage {
	init?(managedFeedImage feedImage: ManagedFeedImage) {
		guard let id = feedImage.id,
		      let url = feedImage.url
		else {
			return nil
		}
		self.init(id: id, description: feedImage.imageDescription, location: feedImage.location, url: url)
	}
}
