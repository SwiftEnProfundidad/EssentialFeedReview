//
//  LoadFeedFromRemoteUseCaseTest.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 2/7/24.
//

import EssentialFeed
import XCTest

final class LoadFeedFromRemoteUseCaseTest: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestDataFromURL() {
        // Arrange: Given a client and sut
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT()

        // Act: When we invoke sut.load()
        sut.load { _ in }

        // Assert: Then assert that a URL request was initiated in the client
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT()

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        for (index, code) in samples.enumerated() {
            expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.invalidData), when: {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponoseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!
        )

        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "http://a-url.com")!, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file _: StaticString = #file,
                         line _: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)

        return (sut, client)
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL
        )

        let json = [
            "id": item.id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString,
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    func expect(_ sut: RemoteFeedLoader,
                toCompleteWith expectedResult: RemoteFeedLoader.Result,
                when action: () -> Void,
                file: StaticString = #file,
                line: UInt = #line)
    {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (.failure(receivedError as RemoteFeedLoader.Error),
                      .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        waitForExpectations(timeout: 1)
    }
}
