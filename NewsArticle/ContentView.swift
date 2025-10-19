

import SwiftUI
import CoreData
import UIKit


struct ContentView: View {
    @ObservedObject var newsViewModel = ViewModel()
    @State var bookmarkedArticless: [Article] = []
    @State var searchText:String = ""
    @State private var currentSegment:SegmentView = .All
    var segmentView:[SegmentView] = [.All, .Bookmarked]
   
    var body: some View {
        NavigationStack {
            VStack
            {
                Picker("", selection: $currentSegment) {
                    ForEach(segmentView, id: \.self) {
                        Text($0.rawValue)
                    }
                }.pickerStyle(.segmented)
                
                Text("Pull to refresh").font(.system(size: 12))
                List {
                    ForEach( searchText.isEmpty ? (currentSegment == .All ? newsViewModel.articles : bookmarkedArticless) :
                                (  currentSegment == .All ? newsViewModel.articles.filter({ article in
                        article.title?.lowercased().contains(searchText.lowercased()) ?? false
                    }) :  bookmarkedArticless.filter({ article in
                        article.title?.lowercased().contains(searchText.lowercased()) ?? false
                    }))
                    ,id: \.title) { article in
                       
                        VStack {
                            
                            HStack(spacing:20)
                            {
                                
                                Image(systemName: "star.fill").frame(width: 20, height: 20).foregroundColor(bookmarkedArticless.contains {$0 == article} ? Color.orange : Color.gray).onTapGesture {
                                    if bookmarkedArticless.contains(article)
                                    {
                                        bookmarkedArticless.removeAll { $0.title == article.title}
                                        PersistenceController.shared.makeBookmark(bookmark: false, article: article)
                                    }
                                    else
                                    {
                                        bookmarkedArticless.append(article)
                                        PersistenceController.shared.makeBookmark(bookmark: true, article: article)
                                    }
                                }
                                
                                self.fetchAndDisplayImage(article: article)
                                
                                VStack(alignment: .leading, spacing: 20)
                                {
                                    Text(article.title ?? "").font(.system(size: 15)) .lineLimit(2)
                                    Text(article.author ?? "").font(.system(size: 15)).bold()
                                }
                            }
                        }
                    }
                    
                }.searchable(text: $searchText).refreshable {
                  await  newsViewModel.fetchNewsData()
                }.navigationTitle("News Articles")
                
            }
        }.task {
            PersistenceController.shared.fetchNewsArticles()
            if PersistenceController.shared.savedNewsArticles.count == 0 // Get data from Server
            {
               await newsViewModel.fetchNewsData()
            }
            else // Get data from CoreData
            {
                newsViewModel.articles = []
                bookmarkedArticless = []
                PersistenceController.shared.savedNewsArticles.forEach { savedArticle in
                   
                    let newsItem = Article(author: savedArticle.author ?? "", title: savedArticle.title ?? "", description: "", urlToImage:  "",imageData: savedArticle.urlToImage)
                    newsViewModel.articles.append(newsItem)
                    if savedArticle.bookmarked == true
                    {
                        bookmarkedArticless.append(newsItem)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func fetchAndDisplayImage(article:Article) -> some View{
        if let imageData = article.imageData, let uiImage = UIImage(data: imageData)
        {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width:70,height: 70)
        } else if let imageURLString = article.urlToImage {
            AsyncImage(url: URL(string: imageURLString)) { image in
                switch image {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width:70,height: 70)
                default:
                    ProgressView()
                }
            }
        }
    }
}

enum SegmentView:String
{
    case All
    case Bookmarked
}

#Preview {
    ContentView()
}

