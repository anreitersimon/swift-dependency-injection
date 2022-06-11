# swift-dependency-injection

Library assisted by a Plugin to reduce some of the complexity/boilerplate around DependencyInjection.
It is designed to also work well in a modularized code-base.

Your Dependencies can be defined (mostly) in the TypeSystem

TODO: Add more explanation


## Quickstart
* Add a dependency on the `DependencyInjection` target
* Apply the plugin `DependencyInjectionPlugin` to target
* Declare a type as Injectable by conforming to one of these protocols
  * `Injectable` Whenever this is injected a new "instance" will be constructed
  * `Singleton` Only one instance will be created, once created it will be kept in memory
  * `WeakSingleton` Only one instance will be created, once the instance is no longer referenced it will be deallocated
* Use `@Inject` or `@Assisted` on arguments of a types initializer


## Declaring Dependencies

To demonstrate how to use `SwiftDependencyInjection` lets start with a example.

```swift
class APIService: Injectable {
  init() {}

  func request(url: URL) -> Data
}


class UserRepository: Injectable {
  let apiService: APIService

  init(@Inject apiService: APIService) {
    self.apiService = apiService
  }

  func listUsers() -> [User]
}

class UserListViewModel: Injectable {
  let repository: UserRepository

  init(@Inject repository: UserRepository) {
    self.repository = apiService
  }
}


// Now instead of this

let apiService = APIService()
let repository = UserRepository(apiService: apiService)
let viewModel = UserListViewModel(repository: repository)

// You can just write

let viewModel = Dependencies.newInstance()

// the `newInstance` method is automatically generated
```

## `Singleton` and `WeakSingleton`
When a type is declared as `Injectable` a new instance of it will be created whenver it is injected.

If thats not the desired behaviour a type can be declared as either `Singleton` or `WeakSingleton`

* `Singleton` Only one instance will be created, once created it will be kept in memory
* `WeakSingleton` Only one instance will be created, once the instance is no longer referenced it will be 

```swift
class UserRepository: Singleton {
  let apiService: APIService

  init(@Inject apiService: APIService) {
    self.apiService = apiService
  }

  func listUsers() -> [User]
}

// You can obtain a reference to it using

let repository = UserRepository.getInstance()
```

## Custom Bindings
In some situations types cannot be injected by conforming to any of the protocols.
Since the conformance has to be done in the type declaration (not in a extension) this is the case when you need to inject types from a third-party library.

In this case you can declare manual bindings

To do that you need to add a extension to one of these types
* `Dependencies.Factories`
* `Dependencies.Singletons`
* `Dependencies.WeakSingletons`

and declare a static method named `bind`
the return type declared by the method can now also be injected.

All arguments of that method will be injected (like when using the `@Inject` annotation in a Initializer)

```swift

// you can control the storage by declaring a extension
extension Dependencies.Singletons {

  // the method must be named 'bind'
  func bind() -> ThirdPartyLibrary.SomeClass {
    return ThirdPartyLibrary.SomeClass()
  }

  // This is also useful if you want to inject a protocol
  func bind(repository: UserRepository) -> UserRepositoryProtocol {
    return repository
  }

}
```



