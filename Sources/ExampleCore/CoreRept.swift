import DependencyInjection
import Foundation

protocol RepoProtocol {}


public class CoreRepository: Singleton, RepoProtocol {
    init(
        @Inject service: Service
    ) {
        print("")
    }

}

struct Service: Injectable {
    init(@Inject api: API) {}
}

struct API: Injectable {}

public protocol AProtocol {}

