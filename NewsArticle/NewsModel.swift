
import Foundation

struct NewsDataModel: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

// MARK: - Article
struct Article: Codable,Equatable
{
    let author, title, description: String?
    let urlToImage: String?
    let imageData:Data?
    static func == (lhs: Article, rhs:Article) -> Bool
    {
        return lhs.title == rhs.title
    }
}
