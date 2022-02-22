import Combine
import ComposableArchitecture
import SwiftUI

struct StreamsListView: View {
    let store: Store<StreamsListState, StreamsListAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                NavigationView {
                    List {
                        ForEach(viewStore.streams) { stream in
                            NavigationLink(
                                destination: StreamDetailPageView(
                                    store: .init(
                                        initialState: StreamDetailState.init(id: stream.id),
                                        reducer: streamDetailReducer,
                                        environment: .live
                                    )
                                )
                            ) {
                                RepositoryView(store: store, stream: stream)
                            }
                            .listRowBackground(Color.codGrey)
                        }
                    }
                    .listStyle(.grouped)
                    .navigationTitle("Streams")
                    .refreshable {
                        viewStore.send(.onRefresh)
                    }
                }
                .navigationBarColor(UIColor(named: "codGrey"))
                .onAppear { viewStore.send(.onAppear) }
                .alert(self.store.scope(state: { $0.alert }), dismiss: .dismissAlertButtonTapped)
                
                if viewStore.isActivityIndicatorVisible {
                    Spinner(isAnimating: true, style: .large)
                }
            }
        }
    }
}

struct RepositoryView: View {
    let store: Store<StreamsListState, StreamsListAction>
    let stream: StreamsListModel
    
    private var spinner: Spinner { Spinner(isAnimating: true, style: .large) }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(alignment: .top, spacing: 0) {
                asyncImage(for: stream.cover)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .frame(width: 130, height: 118)
                    .padding([.bottom, .top], 10)
                VStack(alignment: .leading, spacing: 8) {
                    Text(stream.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.white)
                        .padding(.top, 42)
                        .font(.system(size: 17, weight: .bold, design: .default))
                    Text(stream.description)
                        .clipped()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.white)
                        .font(.system(size: 13, weight: .regular, design: .default))
                }
                .offset(x: 16)
                .padding(
                    EdgeInsets(
                        top: 0,
                        leading: 16,
                        bottom: 16,
                        trailing: 16
                    )
                )
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
        }
        .background(Color.shark)
    }
    
    private func asyncImage(for urlString: String?) -> some View {
        return AsyncImage(
            urlString: urlString,
            placeholder: Image.appleLogoPlaceholder,
            spinner: self.spinner,
            configuration: { $0.resizable() }
        )
    }
}
