// © 2025  Cristian Felipe Patiño Rojas. Created on 2/6/25.


import SwiftUI
import AsyncView

// Original UI by Matteo Manferdini:
// https://matteomanferdini.com/swift-rest-api

struct StackOverflowApp: View {
    private let url = "https://api.stackexchange.com/2.3/questions?pagesize=25&order=desc&sort=votes&site=stackoverflow"
    
    var body: some View {
        NavigationView {
            List {
                AsyncView(url, keyPath: "items") { result in
                    ForEach(result.array, id: \.title) { item in
                        NavigationLink(destination: detail(item), label: {cell(item)})
                    }
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .navigationTitle("Top Questions")
        }
    }
    
    func cell(_ item: JSON) -> Cell {
        Cell(
            title: item.title.string,
            tags: item.tags.array.map { $0.string },
            date: item.creation_date.double,
            score: item.score.int,
            answerCount: item.answer_count.int,
            viewCount: item.view_count.int
        )
    }
    
    func detail(_ item: JSON) -> some View {
        let owner = item.owner
        return Detail(
            id: item.question_id.int,
            title: item.title.string,
            tags: item.tags.array.map { $0.string },
            date: item.creation_date.double,
            content: content(id:),
            owner: Owner(avatarURL: owner.profile_image.string, profileName: owner.profile_name.string, reputation: owner.reputation.int)
        )
    }
}

// UI
extension StackOverflowApp {
    struct CommonMetaData: View {
        let title: String
        let tags: [String]
        let date: TimeInterval
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(try! AttributedString(markdown: title)).font(.headline)
                
                Text(format(tags))
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.accentColor)
                
                Text(format(date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        func format(_ tags: [String]) -> String {
            tags[0] + tags.dropFirst().reduce("") { $0 + ", " + $1 }
        }
        
        func format(_ timestamp: TimeInterval) -> String {
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return "Asked on \(formatter.string(from: date))"
        }
    }
    
    struct Cell: View {
        let title: String
        let tags: [String]
        let date: TimeInterval
        let score: Int
        let answerCount: Int
        let viewCount: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                CommonMetaData(
                    title: title,
                    tags: tags,
                    date: date
                )
                
                HStack(spacing: 24) {
                    Label(score.description, systemImage: "arrowtriangle.up.circle")
                    Label(answerCount.description, systemImage: "ellipses.bubble")
                    Label(viewCount.description, systemImage: "eye")
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
        }
    }
    
    struct Detail<Content: View>: View {
        let id: Int
        let title: String
        let tags: [String]
        let date: TimeInterval
        let content: (Int) -> Content
        let owner: Owner
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    CommonMetaData(
                        title: title,
                        tags: tags,
                        date: date
                    )
                    
                    content(id)
                    owner
                }
                .padding(.horizontal)
            }
        }
    }
    
    struct Owner: View {
        let avatarURL: String?
        let profileName: String
        let reputation: Int
        var body: some View {
            HStack(spacing: 16) {
                Spacer()
                AsyncImage(url: avatarURL.flatMap(URL.init(string:))) { image in
                    image.resizable()
                        .frame(width: 48, height: 48)
                        .cornerRadius(8)
                        .foregroundColor(.secondary)
                } placeholder: {
                    ProgressView()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileName)
                    Text(reputation.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    func content(id: Int) -> some View {
        AsyncView("https://api.stackexchange.com/2.3/questions/\(id)?order=desc&sort=activity&site=stackoverflow&filter=withbody", keyPath: "items") { json in
            let item = json.array[0]
            let title = item.title.string
            Text(try! AttributedString(markdown: title))
        }
    }
}


// Format
extension StackOverflowApp {
    
    func format(_ tags: [String]) -> String {
        tags[0] + tags.dropFirst().reduce("") { $0 + ", " + $1 }
    }
    
    func format(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return "Asked on \(formatter.string(from: date))"
    }
}
