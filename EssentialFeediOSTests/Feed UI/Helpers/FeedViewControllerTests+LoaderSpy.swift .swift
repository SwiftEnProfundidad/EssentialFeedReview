//
//  FeedViewControllerTests+LoaderSpy.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import EssentialFeed
import EssentialFeediOS
import Foundation

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        // MARK: - FeedLoader

        private var feedRequest = [(FeedLoader.Result) -> Void]()

        var loadFeedCallCount: Int {
            feedRequest.count
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequest.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequest[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequest[index](.failure(error))
        }

        // MARK: - FeedImageDataLoader

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void

            func cancel() {
                cancelCallBack()
            }
        }

        private var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedImageURLs: [URL] {
            imageRequest.map(\.url)
        }

        private(set) var cancelledImageURLs = [URL]()

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequest.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequest[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequest[index].completion(.failure(error))
        }

        func cancelImageDataLoading(from url: URL) {
            cancelledImageURLs.append(url)
        }
    }
}
