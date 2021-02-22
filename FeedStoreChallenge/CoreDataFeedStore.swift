import CoreData

enum CoreDataFeedStoreError: Error {
	case invalidModel
}
public class CoreDataFeedStore: FeedStore {
	private let modelName = "CoreDataFeedStoreModel"
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL) throws {
		guard let url = Bundle(for: CoreDataFeedStore.self).url(forResource: modelName, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: url) else {
			throw CoreDataFeedStoreError.invalidModel
		}
		let description = NSPersistentStoreDescription(url: storeURL)
		let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw $0 }
		self.container = container
		self.context = container.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform {
			let coreDataFeed = CoreDataFeed(context: self.context)
			coreDataFeed.timestamp = timestamp
			let images = NSOrderedSet(array: feed.map { local in
				let coreDataFeedImage = CoreDataFeedImage(context: self.context)
				coreDataFeedImage.id = local.id
				coreDataFeedImage.desc = local.description
				coreDataFeedImage.location = local.location
				coreDataFeedImage.url = local.url
				return coreDataFeedImage
			})
			coreDataFeed.feedImages = images
			
			do {
				try self.context.save()
				completion(nil)
			}catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform {
			let request = NSFetchRequest<CoreDataFeed>(entityName: "CoreDataFeed")
			do {
				if let coreDataFeed = try self.context.fetch(request).first, let feedImages = coreDataFeed.feedImages, let timestamp = coreDataFeed.timestamp {
					completion(.found(feed: feedImages.compactMap({$0 as? CoreDataFeedImage}).compactMap({
						guard let id = $0.id else { return nil }
						guard let url = $0.url else { return nil }
						return LocalFeedImage(id: id, description: $0.desc, location: $0.location, url: url)
					}), timestamp: timestamp))
				}else{
					completion(.empty)
				}
			}catch{
				completion(.failure(error))
			}
		}
	}
}
