import DependencyInjection
import Foundation

public struct CoreRepository: Injectable {

    init(
        @Inject service: Service
    ) {
        print("")
    }

}

struct Service: Injectable {
    init(@Inject api: API) {}
}

struct API: Injectable {
}

public protocol AProtocol {}
