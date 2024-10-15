//
//  FeedLoaderWithFallbackCompositeTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 15/10/24.
//

import EssentialFeed
import XCTest

class FeedLoaderWithFallbackComposite {
    private let primary: FeedLoader

    init(primary: FeedLoader, fallback _: FeedLoader) {
        self.primary = primary
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTest: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        let exp = XCTestExpectation(description: "Wait for load completion")

        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)

            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Helpers

private func uniqueFeed() -> [FeedImage] {
    [
        FeedImage(id: UUID(),
                  description: "any",
                  location: "any",
                  url: URL(string: "http://any-url.com")!),
    ]
}

private class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
