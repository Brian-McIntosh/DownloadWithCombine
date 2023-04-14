# Download With Combine

Swiftful Thinking: https://www.youtube.com/watch?v=fdxFp5vU6MQ&list=PLwvDm4VfkdpiagxAXCT33Rkwnc5IVhTar&index=25

Data Source: https://jsonplaceholder.typicode.com/posts

* Available from iOS 13
* Publishers and Subscribers
* Nick's metaphor:
  1. Sign up for monthly subscription for package to be delivered
  2. The company makes the package behind the scene
  3. Receive the package at your front door
  4. Make sure the isn't damaged
  5. Open and make sure the item is correct
  6. Use the item!!
  7. Cancellable at any time!!!

### ViewModel:

```swift
@Published var posts: [PostModel] = []
var cancellables = Set<AnyCancellable>()
    
init() {
    getPosts()
}
    
func getPosts() {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        return
    }
    URLSession.shared.dataTaskPublisher(for: url)
        .subscribe(on: DispatchQueue.global(qos: .background))
        .receive(on: DispatchQueue.main)
        .tryMap { (data, response) -> Data in
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return data
          }
        .decode(type: [PostModel].self, decoder: JSONDecoder())
        .sink { (completion) in
            print("COMPLETION: \(completion)")
        } receiveValue: { [weak self] (returnedPosts) in
            self?.posts = returnedPosts
        }
        .store(in: &cancellables)
    }
}
```
