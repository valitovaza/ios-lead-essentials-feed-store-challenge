//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

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
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = try makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = try makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
		let sut = try makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		return try CoreDataFeedStore(storeURL: storeURL)
	}
	
	func activateNSManagedObjectContextRetrievalFailure() {
		toggleNSManagedObjectContextRetrieveTestFailure()
	}
	
	func deactivateNSManagedObjectContextRetrievalFailure() {
		toggleNSManagedObjectContextRetrieveTestFailure()
	}
	
	func activateNSManagedObjectContextSaveFailure() {
		toggleNSManagedObjectContextSaveTestFailure()
	}
	
	func deactivateNSManagedObjectContextSaveFailure() {
		toggleNSManagedObjectContextSaveTestFailure()
	}
	
	func activateNSManagedObjectContextDeleteFailure() {
		//core data doesn't fail on deletion, it fails on save
		toggleNSManagedObjectContextSaveTestFailure()
	}
	
	func deactivateNSManagedObjectContextDeleteFailure() {
		//core data doesn't fail on deletion, it fails on save
		toggleNSManagedObjectContextSaveTestFailure()
	}
	
	private func toggleNSManagedObjectContextRetrieveTestFailure() {
		Swizzling.sExchangeInstance(cls1: NSManagedObjectContext.self, sel1: #selector(NSManagedObjectContext.fetch(_:)), cls2: FailingContext.self, sel2: #selector(FailingContext.fetch(_:)))
	}
	
	private func toggleNSManagedObjectContextSaveTestFailure() {
		Swizzling.sExchangeInstance(cls1: NSManagedObjectContext.self, sel1: #selector(NSManagedObjectContext.save), cls2: FailingContext.self, sel2: #selector(FailingContext.save))
	}
	
	private class Swizzling: NSObject {
		
		class func sExchangeInstance(cls1: AnyClass, sel1: Selector, cls2: AnyClass, sel2: Selector) {

			let originalMethod = class_getInstanceMethod(cls1, sel1)
			let swizzledMethod = class_getInstanceMethod(cls2, sel2)

			method_exchangeImplementations(originalMethod!, swizzledMethod!)
		}
		
	}
	
	private class FailingContext {
		
		@objc func fetch(_ request: NSFetchRequest<NSNumber>) throws -> [NSNumber] {
			throw anyError()
		}
		
		private func anyError() -> NSError {
			NSError(domain: "any-error", code: 0)
		}
		
		@objc func save() throws {
			throw anyError()
		}
	}
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

	func test_retrieve_deliversFailureOnRetrievalError() throws {
		let sut = try makeSUT()
		
		activateNSManagedObjectContextRetrievalFailure()
		
		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
		
		deactivateNSManagedObjectContextRetrievalFailure()
	}

	func test_retrieve_hasNoSideEffectsOnFailure() throws {
		let sut = try makeSUT()

		activateNSManagedObjectContextRetrievalFailure()
		
		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
		
		deactivateNSManagedObjectContextRetrievalFailure()
	}

}

extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {

	func test_insert_deliversErrorOnInsertionError() throws {
		let sut = try makeSUT()

		activateNSManagedObjectContextSaveFailure()
		
		assertThatInsertDeliversErrorOnInsertionError(on: sut)
		
		deactivateNSManagedObjectContextSaveFailure()
	}

	func test_insert_hasNoSideEffectsOnInsertionError() throws {
		let sut = try makeSUT()

		activateNSManagedObjectContextSaveFailure()
		
		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
		
		deactivateNSManagedObjectContextSaveFailure()
	}

}

extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {

	func test_delete_deliversErrorOnDeletionError() throws {
		let sut = try makeSUT()

		activateNSManagedObjectContextDeleteFailure()
		
		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
		
		deactivateNSManagedObjectContextDeleteFailure()
	}

	func test_delete_hasNoSideEffectsOnDeletionError() throws {
		let sut = try makeSUT()
		
		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
	}

}
