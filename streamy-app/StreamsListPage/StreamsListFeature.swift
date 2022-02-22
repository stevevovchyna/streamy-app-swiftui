import Combine
import ComposableArchitecture

struct StreamsListState: Equatable {
    var streams: [StreamsListModel] = []
    
    var alert: AlertState<StreamsListAction>? = nil
    var isActivityIndicatorVisible = true
    
    var streamDetail: StreamDetailState {
        get { .init(stream: StreamDetailPageModel(name: "", description: "", url: "", id: "", streamID: ""), id: "", alert: nil) }
        set { (self.alert) = (nil) }
    }
}

enum StreamsListAction: Equatable {
    case onAppear
    case dataLoaded(Result<[StreamsListModel], APIError>)
    case onRefresh
    
    case dismissAlertButtonTapped
    
    case streamDetail(StreamDetailAction)
}

struct StreamsListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var stream: StreamClient
    
    static let live = Self(
        mainQueue: .main,
        uuid: UUID.init,
        stream: .live
    )
}

let streamsListReducer = Reducer<StreamsListState, StreamsListAction, StreamsListEnvironment>.combine(
    .init { state, action, environment in
        switch action {
        case .onAppear:
            state = .init()
            state.isActivityIndicatorVisible = true
            return environment.stream
                .list()
                .receive(on: environment.mainQueue)
                .catchToEffect(StreamsListAction.dataLoaded)
        case .onRefresh:
            state.isActivityIndicatorVisible = true
            return environment.stream
                .list()
                .receive(on: environment.mainQueue)
                .catchToEffect(StreamsListAction.dataLoaded)
        case .dataLoaded(let result):
            state.isActivityIndicatorVisible = false
            switch result {
            case .success(let streams):
                state.streams = streams
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
        default:
            return .none
        }
    },
    streamDetailReducer.pullback(
        state: \.streamDetail,
        action: /StreamsListAction.streamDetail,
        environment: { _ in .init(stream: .live, mainQueue: .main) }
    )
)
