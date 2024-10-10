//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 7/10/24.
//

import XCTest

struct FeedErrorViewModel {
    let errorMessage: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(errorMessage: nil)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    private var errorView: FeedErrorView
    private var loadingView: FeedLoadingView

    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
}

final class FeedPresenterTest: XCTestCase {
    func test_init_doesNotSendMessagegesToView() {
        let (_, view) = makeSUT()

        _ = FeedPresenter(loadingView: view, errorView: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingFeed_displayLoadingMessageAndStartLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: #file, line: #line)
        trackForMemoryLeaks(view, file: #file, line: #line)
        return (sut, view)
    }

    private class ViewSpy: FeedLoadingView, FeedErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }

        private(set) var messages = Set<Message>()

        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.errorMessage))
        }

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
