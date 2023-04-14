//
//  ContentView.swift
//  DownloadWithCombine
//
//  Created by Brian McIntosh on 4/13/23.
//

import SwiftUI
import Combine

/*
 Swiftful Thinking - https://www.youtube.com/watch?v=fdxFp5vU6MQ&list=PLwvDm4VfkdpiagxAXCT33Rkwnc5IVhTar&index=25
 Data Source: https://jsonplaceholder.typicode.com/posts
*/

struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class DownloadWithCombineViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return
        }
        
        /*
         • Nick's metaphor:
             1. Sign up for monthly subscription for package to be delivered
             2. The company makes the package behind the scene
             3. Receive the package at your front door
             4. Make sure the isn't damaged
             5. Open and make sure the item is correct
             6. Use the item!!
             7. Cancellable at any time!!!
         */
        
        // 1. create the publisher
        URLSession.shared.dataTaskPublisher(for: url)
            // 2. subscribe publisher on background thread
            // note: this is done by default, but let's go through the motions
            .subscribe(on: DispatchQueue.global(qos: .background))
            // 3. receive on main thread
            .receive(on: DispatchQueue.main)
            // 4. tryMap (check that the data is good)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            // 5. decode (decode data into PostModels)
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            // 6. sink (put the item into our app)
            .sink { (completion) in
                print("COMPLETION: \(completion)")
            } receiveValue: { [weak self] (returnedPosts) in
                self?.posts = returnedPosts
            }
            // 7. store (cancel subscription if needed)
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @StateObject var vm = DownloadWithCombineViewModel()
    var body: some View {
        List {
            ForEach(vm.posts) { post in
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
