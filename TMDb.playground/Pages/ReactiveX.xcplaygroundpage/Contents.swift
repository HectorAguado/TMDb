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

let randomUserImage =
    session.rx.data(request: URLRequest(url: randomUserApiUrl))
        .map { data -> RandomUserResponse in
            try decoder.decode(RandomUserResponse.self, from: data)
        }
        .flatMap{ response -> Observable<Data> in
            let request = URLRequest(url: response.results[0].picture.imageURL)
            return session.rx.data(request: request)
        }
        .map { data -> UIImage in
            UIImage(data: data) ?? UIImage()
        }


let disposable = randomUserImage.subscribe(
    onNext: {image in
        let myImage = image
    },
    onError: {error in
        print(error)
    },
    onCompleted: nil,
    onDisposed: nil
)


//let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
//
//let size: CGSize? = cell.imageView?.image?.size
//let otherSize = cell.imageView
//    .flatMap { $0.image }
//    .flatMap { $0.size}

//let randomUserImage = session.rx.data(request: URLRequest(url: randomUserApiUrl))
//    .map { data -> RandomUserResponse in
//        try decoder.decode(RandomUserResponse.self, from: data)
//    }
//    .flatMap { response -> Observable<Data> in
//        let request = URLRequest(url: response.results[0].picture.imageURL)
//        return session.rx.data(request: request)
//    }
//    .map { data -> UIImage in
//        UIImage(data: data) ?? UIImage()
//    }
//
//let disposable = randomUserImage.subscribe(onNext: { image in
//    let stupidXcode = image
//}, onError: { error in
//    print(error)
//})
