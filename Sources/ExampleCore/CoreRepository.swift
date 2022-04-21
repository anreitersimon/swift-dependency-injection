import Foundation
import SwiftDagger

public struct CoreRepository: Injectable {
    init(service: Service) {
        print("")
    }
}

struct Service: SwiftDagger.Injectable {
    init(api: API) {}
}



struct API: SwiftDagger.Injectable {
}
