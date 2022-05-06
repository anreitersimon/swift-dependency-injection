public protocol Scoped {
    associatedtype Scope: DependencyScope = GlobalScope
}

/// Whenever this is injected a new Instance will be created
public protocol Injectable: Scoped {}

/// Only a single Instance will be created and wont be deallocated
public protocol Singleton: Scoped {}

/// Only a single Instance will be created at the same time
/// If the instance is no longer referenced it will be deallocated and newly created when accessed again
public protocol WeakSingleton: AnyObject, Scoped {}
