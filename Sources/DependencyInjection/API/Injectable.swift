/// Whenever this is injected a new Instance will be created
public protocol Injectable {
    associatedtype Scope: DependencyScope = GlobalScope
    associatedtype Qualifier: QualifierDefinition = Qualifiers.Default
}

/// Only a single Instance will be created and wont be deallocated
public protocol Singleton {
    associatedtype Scope: DependencyScope = GlobalScope
    associatedtype Qualifier: QualifierDefinition = Qualifiers.Default
}

/// Only a single Instance will be created at the same time
/// If the instance is no longer referenced it will be deallocated and newly created when accessed again
public protocol WeakSingleton: AnyObject {
    associatedtype Scope: DependencyScope = GlobalScope
    associatedtype Qualifier: QualifierDefinition = Qualifiers.Default
}
