//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FailableFeedStoreSpecs {
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

	func test_retrieve_deliversFailureOnRetrievalError() throws {
		let stub = NSManagedObjectContext.alwaysFailingFetchStub()
		stub.startIntercepting()

		let sut = try makeSUT()

		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnFailure() throws {
		let stub = NSManagedObjectContext.alwaysFailingFetchStub()
		stub.startIntercepting()

		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
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

	func test_insert_deliversErrorOnInsertionError() throws {
		let stub = NSManagedObjectContext.alwaysFailingSaveStub()
		stub.startIntercepting()

		let sut = try makeSUT()

		assertThatInsertDeliversErrorOnInsertionError(on: sut)
	}

	func test_insert_hasNoSideEffectsOnInsertionError() throws {
		let stub = NSManagedObjectContext.alwaysFailingSaveStub()
		stub.startIntercepting()

		let sut = try makeSUT()

		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
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

	func test_delete_deliversErrorOnDeletionError() throws {
		let stub = NSManagedObjectContext.alwaysFailingExecuteStub()
		let feed = uniqueImageFeed()
		let timestamp = Date()
		let sut = try makeSUT()

		insert((feed, timestamp), to: sut)

		stub.startIntercepting()

		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
	}

	func test_delete_hasNoSideEffectsOnDeletionError() throws {
		let stub = NSManagedObjectContext.alwaysFailingExecuteStub()
		let feed = uniqueImageFeed()
		let timestamp = Date()
		let sut = try makeSUT()

		insert((feed, timestamp), to: sut)

		stub.startIntercepting()

		deleteCache(from: sut)

		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}

	func test_storeSideEffects_runSerially() throws {
		let sut = try makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}

	// - MARK: Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> FeedStore {
		let inMemoryStoreURL = URL(fileURLWithPath: "/dev/null")
		let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
