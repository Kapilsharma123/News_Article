

import Foundation
import Combine
import SwiftUI
class ViewModel:ObservableObject
{
    @Published var articles:[Article] = []
    var dataProvider:DataProvider = DataProvider()
    var cancellables:Set<AnyCancellable> = []
   
    func fetchNewsData() async
    {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=tesla&from=2025-09-19&sortBy=publishedAt&apiKey=6120674a049c495487a24bc9574462a4") else { return }
        dataProvider.fetchNewsData(url: url, type: NewsDataModel.self).sink { completion in
            switch completion
            {
            case .finished:
                print()
            case .failure(let err):
                print("Error==\(err.localizedDescription)")
            }
        } receiveValue: { newsDataModel in
            self.articles = newsDataModel.articles ?? []
            PersistenceController.shared.saveNewRecords(articles: self.articles)
        }
        .store(in: &cancellables)

    }
}
