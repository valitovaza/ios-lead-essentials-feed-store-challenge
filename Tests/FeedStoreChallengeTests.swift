//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

enum CoreDataFeedStoreError: Error {
	case invalidModel
}
class CoreDataFeedStore: FeedStore {
	private let modelName = "CoreDataFeedStoreModel"
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	init(storeURL: URL) throws {
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
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
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
	
	func retrieve(completion: @escaping RetrievalCompletion) {
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

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
//		let sut = try makeSUT()
//
//		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
//		let sut = try makeSUT()
//
//		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
//		let sut = try makeSUT()
//
//		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		return try CoreDataFeedStore(storeURL: storeURL)
	}
	
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
