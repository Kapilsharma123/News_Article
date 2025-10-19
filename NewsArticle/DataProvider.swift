

import Foundation
import Combine

enum CustomError:Error
{
    case nilSelf
}
class DataProvider
{
    var cancellables:Set<AnyCancellable> = []
    func fetchNewsData<T:Decodable>(url:URL, type: T.Type) -> Future<T, Error>
    {
        return Future<T, Error> { [weak self] promise in
            guard let self = self else { return promise(.failure(Error.self as! Error))}
            URLSession.shared.dataTaskPublisher(for: url).tryMap { (data, response) in
                return data
            }.decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion
                    {
                    case .failure(let error):
                        if let decodingError = error as? DecodingError
                        {
                            promise(.failure(decodingError))
                        }
                    default:
                        print()
                    }
                } receiveValue: { resultData in
                    promise(.success(resultData))
                }.store(in: &self.cancellables)

        }
    }
}
