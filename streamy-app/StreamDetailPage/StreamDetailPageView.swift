import AVKit
import Combine
import ComposableArchitecture
import SwiftUI

struct StreamDetailPageView: View {
    let store: Store<StreamDetailState, StreamDetailAction>
    @State var isPlaying: Bool = true
    @State var avPlayer: AVPlayer?
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                ScrollView {
                    VStack {
                        ZStack {
                            if let urlString = viewStore.stream.url,
                               let url = URL(string: urlString)
                            {
                                VideoPlayerView(player: avPlayer)
                                    .onAppear {
                                        avPlayer = AVPlayer(url: url)
                                        avPlayer?.play()
                                        isPlaying = true
                                    }
                                    .onTapGesture { processPlaybackTapGesture() }
                                    .onDisappear {
                                        avPlayer?.pause()
                                        avPlayer = nil
                                    }
                                    .background(Color.black)
                                    .frame(height: 163)
                                    .padding([.leading, .top, .trailing], 16)
                                    .overlay(
                                        playbackOverlay,
                                        alignment: .center
                                    )
                                Image.playeButtonImage
                                    .frame(width: 45, height: 45, alignment: .center)
                                    .opacity(isPlaying ? 0 : 1)
                            } else {
                                /// SHOULD CONTAIN APPROPRIATE PLACEHOLDER VIEW - OUT OF SCOPE
                                Color.black
                            }
                        }
                        Text(viewStore.stream.description)
                            .padding([.leading, .trailing, .top], 16)
                    }
                }
                .navigationTitle(viewStore.stream.name)
                .onAppear { viewStore.send(.onAppear) }
                .alert(self.store.scope(state: { $0.alert }), dismiss: .dismissAlertButtonTapped)
                
                if viewStore.isActivityIndicatorVisible {
                    Spinner(isAnimating: true, style: .large)
                }
            }
        }
    }
    
    
    private var playbackOverlay: some View {
        Color.playbackOverlay
            .opacity(isPlaying ? 0 : 1)
            .onTapGesture { processPlaybackTapGesture() }
    }

    private func processPlaybackTapGesture() {
        if avPlayer?.rate != 0 {
            avPlayer?.pause()
            isPlaying = false
        } else {
            avPlayer?.play()
            isPlaying = true
        }
    }
}
