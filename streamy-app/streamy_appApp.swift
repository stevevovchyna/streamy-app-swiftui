import AVFoundation
import SwiftUI
import ComposableArchitecture

@main
struct streamy_appApp: App {
    var body: some Scene {
        WindowGroup {
            StreamsListView(
                store: .init(
                    initialState: StreamsListState(),
                    reducer: streamsListReducer,
                    environment: .live
                )
            )
        }
    }    
}
