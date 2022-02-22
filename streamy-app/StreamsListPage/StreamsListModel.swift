import Combine
import ComposableArchitecture

struct StreamsListModel: Decodable, Equatable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case name, cover, id
        case description = "shortDescription"
    }
    
    let name: String
    let description: String
    let cover: String?
    let id: String
}
