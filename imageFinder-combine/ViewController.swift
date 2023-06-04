import UIKit
import Combine

class ViewController: UIViewController {
    
    var cancellable: AnyCancellable!
    
    let imageView = UIImageView()
    
    let searchTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        setupSearchTextField()
        setupConstraints()
        setupPublisher()
        
    }
    
    private func setupImageView() {
        
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSearchTextField() {
        
        view.addSubview(searchTextField)
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextField.layer.cornerRadius = 10
        
        searchTextField.layer.borderColor = UIColor.black.cgColor
        
        searchTextField.layer.borderWidth = 2
        
        searchTextField.setLeftPaddingPoints(10)
        
        searchTextField.setRightPaddingPoints(10)
        
        searchTextField.font = UIFont(name: "Avenir", size: 22)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            
            searchTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 100),
            searchTextField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            searchTextField.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05),
            searchTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func setupPublisher() {
        
        cancellable = searchTextField.textPublisher.flatMap { searchText -> URLSession.DataTaskPublisher in
            let url = URL(string: "https://api.pexels.com/v1/search?query=\(searchText!)&per_page=1")!
            var request = URLRequest(url: url)
            request.setValue(AuthKey.key, forHTTPHeaderField: "Authorization")
            return URLSession.shared.dataTaskPublisher(for: request)
        }.tryMap { data -> Data in
            guard let response = data.response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return data.data
        }
        .decode(type: Response.self, decoder: JSONDecoder())
        .map({ response -> UIImage in
            let photo = response.photos[0]
            let photoUrl = URL(string: photo.src.original)
            let photoData = try? Data(contentsOf: photoUrl!)
            return UIImage(data: photoData!)!
        })
        .eraseToAnyPublisher()
        .sink { completion in
            switch completion {
                
            case .finished:
                print("FINISHED")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { response in
            DispatchQueue.main.async {
                self.imageView.image = response
            }
        }
    }
    
}
