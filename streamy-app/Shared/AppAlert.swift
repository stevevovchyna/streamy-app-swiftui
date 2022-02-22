import Foundation

public struct AppAlert: Identifiable {
    public var title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var id: String { self.title }
}
