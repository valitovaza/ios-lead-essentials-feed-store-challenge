import CoreData

public class CoreDataFeedStore: FeedStore {
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL) throws {
		self.container = try NSPersistentContainer.loadBy(modelName: "CoreDataFeedStoreModel", storeURL: storeURL)
		self.context = container.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform {
			do {
				try self.removePreviousCoreDataFeedOptionally()
				try self.context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform {
			do {
				try self.createUniqueCoreDataFeed(feed, timestamp)
				try self.context.save()
				completion(nil)
			} catch {
				self.context.rollback()
				completion(error)
			}
		}
	}
	
	private func createUniqueCoreDataFeed(_ feed: [LocalFeedImage], _ timestamp: Date) throws {
		try self.removePreviousCoreDataFeedOptionally()
		self.createCoreDataFeed(feed, timestamp)
	}
	
	private func removePreviousCoreDataFeedOptionally() throws {
		guard let oldFeed = try self.retrieveCoreDataFeed() else { return }
		context.delete(oldFeed)
	}
	
	private func createCoreDataFeed(_ feed: [LocalFeedImage], _ timestamp: Date) {
		let coreDataFeed = CoreDataFeed(context: context)
		coreDataFeed.timestamp = timestamp
		let images = NSOrderedSet(array: feed.map { local in
			let coreDataFeedImage = CoreDataFeedImage(context: context)
			coreDataFeedImage.id = local.id
			coreDataFeedImage.desc = local.description
			coreDataFeedImage.location = local.location
			coreDataFeedImage.url = local.url
			return coreDataFeedImage
		})
		coreDataFeed.feedImages = images
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform {
			do {
				if let coreDataFeed = try self.retrieveCoreDataFeed(), let feedImages = coreDataFeed.feedImages, let timestamp = coreDataFeed.timestamp {
					completion(.found(feed: feedImages.toLocalFeedImages, timestamp: timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	private func retrieveCoreDataFeed() throws -> CoreDataFeed? {
		let request = NSFetchRequest<CoreDataFeed>(entityName: "CoreDataFeed")
		return try self.context.fetch(request).first
	}
}

enum CoreDataFeedStoreError: Error {
	case invalidModel
}

private extension NSPersistentContainer {
	static func loadBy(modelName: String, storeURL: URL) throws -> NSPersistentContainer {
		guard let url = Bundle(for: CoreDataFeedStore.self).url(forResource: modelName, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: url) else {
			throw CoreDataFeedStoreError.invalidModel
		}
		let description = NSPersistentStoreDescription(url: storeURL)
		let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw $0 }
		return container
	}
}

private extension NSOrderedSet {
	var toLocalFeedImages: [LocalFeedImage] {
		compactMap({$0 as? CoreDataFeedImage}).compactMap({
			guard let id = $0.id else { return nil }
			guard let url = $0.url else { return nil }
			return LocalFeedImage(id: id, description: $0.desc, location: $0.location, url: url)
		})
	}
}
