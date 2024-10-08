//
//  FeedViewControllerTests+Assertions.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

extension FeedUIIntegrationTests {
    func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let view = sut.feedImagesView(at: index)

        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index)",
            file: file,
            line: line
        )

        XCTAssertEqual(
            cell.locationLabel.text,
            image.location,
            "Expected location text to be \(String(describing: image.location)) for image view at index (\(index))",
            file: file,
            line: line
        )

        XCTAssertEqual(
            cell.descriptionLabel.text,
            image.description,
            "Expected description text to be \(String(describing: image.description)) for image view at index (\(index))",
            file: file,
            line: line
        )
    }

    func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }

        for (index, image) in feed.enumerated() {
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
}
