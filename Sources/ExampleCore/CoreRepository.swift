import Foundation
import DependencyInjection

public struct CoreRepository: Injectable {
    init(service: Service) {
        print("")
    }
}

struct Service: DependencyInjection.Injectable {
    init(api: API) {}
}



struct API: DependencyInjection.Injectable {
}
