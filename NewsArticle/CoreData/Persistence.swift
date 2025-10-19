
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    var savedNewsArticles:[NewsEntity] = []

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NewsArticle")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
           
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveNewRecords(articles: [Article])
    {
        articles.forEach { article in
            downloadImageData(from: article.urlToImage ?? "") { downloadedData in
                if let data = downloadedData {
                    DispatchQueue.main.async {
                        let newArticle = NewsEntity(context: self.container.viewContext)
                        newArticle.title = article.title ?? ""
                        newArticle.author = article.author ?? ""
                        newArticle.urlToImage = data
                        newArticle.bookmarked = false
                        self.saveRecords()
                    }
                }
            }
        }
        
    }
    
    func saveRecords()
    {
        do
        {
            try self.container.viewContext.save()
        }
        catch let error
        {
            print("Error while saving records=\(error)")
        }
    }
    func fetchNewsArticles()
    {
        let request = NSFetchRequest<NewsEntity>(entityName: "NewsEntity")
        do
        {
            self.savedNewsArticles = try container.viewContext.fetch(request)
        }
        catch let error
        {
            print("Error fetching News articles==\(error)")
        }
    }
    
    func makeBookmark(bookmark:Bool,article:Article)
    {
       PersistenceController.shared.fetchNewsArticles()
       let articles = PersistenceController.shared.savedNewsArticles.filter{ $0.title == article.title}
       articles.first?.bookmarked = bookmark
       self.saveRecords()
    }
    
    func downloadImageData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
    
}

