import Combine
import ComposableArchitecture

struct StreamDetailState: Equatable {
    var stream: StreamDetailPageModel = StreamDetailPageModel(
        name: "",
        description: "",
        url: nil,
        id: "",
        streamID: ""
    )
    
    var id: String
    
    var alert: AlertState<StreamDetailAction>? = nil
    var isActivityIndicatorVisible = true
}

enum StreamDetailAction: Equatable {
    case onAppear
    case dataLoaded(Result<[StreamDetailPageModel], APIError>)
    
    case dismissAlertButtonTapped
}

struct StreamDetailEnvironment {
    var stream: StreamClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    static let live = Self(
        stream: .live,
        mainQueue: .main
    )
}

let streamDetailReducer = Reducer<
    StreamDetailState,
    StreamDetailAction,
    StreamDetailEnvironment
>
{ state, action, environment in
    switch action {
    case .onAppear:
        state.isActivityIndicatorVisible = true
        return environment.stream.detail(state.id)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(StreamDetailAction.dataLoaded)
    case .dataLoaded(let result):
        state.isActivityIndicatorVisible = false
        switch result {
        case .success(let stream):
            if let unwrappedStream = stream.first {
                state.stream = unwrappedStream
            } else {
                state.alert = .init(title: TextState("No data returned from the server. Please try another request"))
            }
        case .failure(let error):
            switch error {
            case .downloadError:
                state.alert = .init(title: TextState("Download error. Please try again"))
            case .decodingError:
                state.alert = .init(title: TextState("Decoding error. Please update the app"))
            }
        }
        return .none
    case .dismissAlertButtonTapped:
        state.alert = nil
        return .none
    }
}
