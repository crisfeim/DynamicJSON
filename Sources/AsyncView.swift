// © 2025  Cristian Felipe Patiño Rojas. Created on 2/6/25.

import Foundation
import SwiftUI

public struct AsyncView<T: View>: View {
    
    @State var state = ResourceState.loading
    
    let url: URL
    let keyPath: String?
    @ViewBuilder var closure: (JSON) -> T
    
    public init(_ url: URL, keyPath: String? = "results", @ViewBuilder closure: @escaping (JSON) -> T) {
        self.url = url
        self.keyPath = keyPath
        self.closure = closure
    }
    
    public init(_ url: String, keyPath: String? = "results", @ViewBuilder closure: @escaping (JSON) -> T) {
        self.url = URL(string: url)!
        self.keyPath = keyPath
        self.closure = closure
    }
    
    func result(_ JSON: JSON) -> JSON {
        keyPath == nil ? JSON : JSON[keyPath!]
    }

    public var body: some View {
        switch state {
        case .loading: ProgressView().onAppear(perform: fetchData)
        case .success(let data): closure(result(data))
        case .error(let error): Text(error)
        }
    }
    
    private func fetchData() {
        Task {
            do {
                let json = try await JSON(url.absoluteString)
                state = .success(json)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}

enum ResourceState {
    case loading
    case success(JSON)
    case error(String)
}

extension ResourceState {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
    
    var data: JSON? {
        switch self {
        case .success(let data): return data
        default: return nil
        }
    }
}

extension ResourceState {
    init(from result: Result<JSON, Error>) {
        switch result {
        case .success(let data): self = .success(data)
        case .failure(let error): self = .error(error.localizedDescription)
        }
    }
}
