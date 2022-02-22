import SwiftUI

struct AsyncImage<Placeholder: View, Spinner: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder?
    private let spinner: Spinner?
    private let configuration: (Image) -> Image
    
    init(
        urlString: String?,
        placeholder: Placeholder? = nil,
        spinner: Spinner? = nil,
        configuration: @escaping (Image) -> Image = { $0 }
    ) {
        self.placeholder = placeholder
        self.spinner = spinner
        self.configuration = configuration

        _loader = StateObject(wrappedValue: ImageLoader(urlString: urlString, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                configuration(Image(uiImage: loader.image!))
            } else {
                if loader.isLoading {
                    spinner
                } else {
                    placeholder
                }
            }
        }
    }
}
