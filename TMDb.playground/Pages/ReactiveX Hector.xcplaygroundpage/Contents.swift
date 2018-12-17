import TMDbCore
import RxSwift
import RxCocoa

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

struct RandomUserResponse: Decodable {
    struct User: Decodable {
        struct Name: Decodable {
            let title: String
            let first: String
            let last: String
        }
        
        struct Picture: Decodable {
            let imageURL: URL
            
            private enum CodingKeys: String, CodingKey {
                case imageURL = "large"
            }
        }
        
        let name: Name
        let picture: Picture
    }
    
    let results: [User]
}

let randomUserApiUrl = URL(string: "https://randomuser.me/api")!
let session = URLSession(configuration: .default)
let decoder = JSONDecoder()

func data(with url: URL) -> Observable<Data> {
    return Observable.create { observer in
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                observer.onError(error)
            } else {
                observer.onNext(data ?? Data())
                observer.onCompleted()
            }
        }
        
        task.resume()
        return Disposables.create {
            print("jarl")
            task.cancel()
        }
    }
}


func getRandomUserResponse(completion: @escaping (RandomUserResponse?, Error?) -> Void) {
    let task = session.dataTask(with: randomUserApiUrl) { (data, response, error) in
        if let data = data,
            let result = try? decoder.decode(RandomUserResponse.self, from: data) {
            completion(result, nil)
        } else {
            completion(nil, error)
        }
    }
    task.resume()
}

func getImage(for url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
    let task = session.dataTask(with: url) { (data, response, error) in
        if let data = data, let image = UIImage(data: data) {
            completion(image, nil)
        } else {
            completion(nil, error)
        }
    }
    task.resume()
}

func getRandomUserImage(completion: @escaping (UIImage?, Error?) -> Void) {
    getRandomUserResponse { response, error in
        guard let response = response else {
            completion(nil, error)
            return
        }
        
        getImage(for: response.results[0].picture.imageURL, completion: completion)
        
    }
}

getRandomUserImage { image, error in
    if let image = image {
        let myImage = image
    } else if let error = error {
        print(error)
    }
}

let thing = data(with: randomUserApiUrl)
    .map { data -> RandomUserResponse in
        try decoder.decode(RandomUserResponse.self, from: data)
    }
    .flatMap{ response -> Observable<Data> in
        data(with: response.results[0].picture.imageURL)
    }
    .map { data -> UIImage in
        UIImage(data: data) ?? UIImage()
    }


let disposable = thing.subscribe(
    onNext: {image in
        let myImage = image
},
    onError: {error in
        print(error)
},
    onCompleted: nil,
    onDisposed: nil
)
