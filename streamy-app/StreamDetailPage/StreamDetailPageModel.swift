import Foundation

struct StreamDetailPageModel: Decodable, Equatable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case name, url, id
        case streamID = "streamId"
        case description = "detailedDescription"
    }
    
    let name: String
    let description: String
    let url: String?
    let id: String
    let streamID: String
}
