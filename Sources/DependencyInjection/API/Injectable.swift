/// Whenever this is injected a new Instance will be created
public protocol Injectable {}

/// Only a single Instance will be created and wont be deallocated
public protocol Singleton {}

/// Only a single Instance will be created at the same time
/// If the instance is no longer referenced it will be deallocated and newly created when accessed again
public protocol WeakSingleton: AnyObject {}

protocol Scope {}
protocol SingletonScope: Scope {}
protocol ApplicationScope: SingletonScope {}
protocol SceneScope: ApplicationScope {}
protocol ViewControllerScope: SceneScope {}

