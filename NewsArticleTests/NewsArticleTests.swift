

import Testing
import XCTest
@testable import NewsArticle

class NewsArticleTests: XCTestCase {

    func testSuccessfulAPIResponse() async throws {
        let viewModel = ViewModel()
        let expectedResponse = NewsDataModel(status: "ok", totalResults: 1, articles: [Article(author: "", title: "", description: "", urlToImage: "", imageData: nil)])
        viewModel.articles = expectedResponse.articles ?? []
        
        await viewModel.fetchNewsData()
        
        XCTAssertEqual(viewModel.articles, expectedResponse.articles)
    }

}
