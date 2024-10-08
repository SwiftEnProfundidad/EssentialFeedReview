//
//  ValidateFeedCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import EssentialFeed
import XCTest

final class ValidateFeedCacheUseCaseTest: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }

    func test_validate_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validate_doesNotDeleteNonExpiredCache() {
        let feeds = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: feeds.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnSevenDaysOldCache() {
        let feeds = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: feeds.local, timestamp: sevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletesCacheOnExpiration() {
        let feeds = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: feeds.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }

    func test_validateCache_deletesExpiredCache() {
        let feeds = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: feeds.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache()

        sut = nil
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file, line: UInt = #line
    )
        -> (sut: LocalFeedLoader, store: FeedStoreSpy)
    {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
