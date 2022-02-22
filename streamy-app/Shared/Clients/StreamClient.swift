import ComposableArchitecture
import SwiftUI

struct StreamClient {
    var list: () -> Effect<[StreamsListModel], APIError>
    var detail: (String) -> Effect<[StreamDetailPageModel], APIError>
}

extension StreamClient {
    static let host: String = "https://6212727df43692c9c6eb26de.mockapi.io"
    
    static let live = Self(
        list: {
            return URLSession.shared.dataTaskPublisher(for: URL(string: host + "/streams")!)
                .mapError { _ in APIError.downloadError }
                .map { data, _ in data }
                .decode(type: [StreamsListModel].self, decoder: JSONDecoder())
                .mapError { _ in APIError.decodingError }
                .eraseToEffect()
        },
        detail: { id in
            guard let url = URL(string: host + "/streams/\(id)/details") else {
                return Effect(error: APIError.downloadError)
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .mapError { _ in APIError.downloadError }
                .map { data, _ in data }
                .decode(type: [StreamDetailPageModel].self, decoder: JSONDecoder())
                .mapError { _ in APIError.decodingError }
                .eraseToEffect()
        }
    )
}
