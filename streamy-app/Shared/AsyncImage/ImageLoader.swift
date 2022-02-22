import Combine
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private(set) var isLoading = false
    
    private let url: URL?
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(urlString: String?, cache: ImageCache? = nil) {
        if let urlString = urlString {
            self.url = URL(string: urlString)
        } else {
            self.url = nil
        }
        self.cache = cache
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        self.image = nil
        guard !isLoading else { return }
        
        if let url = self.url {
            if let image = cache?[url] {
                isLoading = false
                self.image = image
                return
            }
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                              receiveOutput: { [weak self] in self?.cache($0) },
                              receiveCompletion: { [weak self] _ in self?.onFinish() },
                              receiveCancel: { [weak self] in self?.onFinish() })
                .subscribe(on: Self.imageProcessingQueue)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        } else {
            self.image = nil
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        if let url = self.url {
            image.map { cache?[url] = $0 }
        }
    }
}
