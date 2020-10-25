#  GRDB + SwiftUI Example

There are two types of **view models**
1. **Automatically refreshing** (e.g. using ValueObservations + Combine). They are `ObservableObjects` and should be bound to the View's lifecycle by `@StateObject`. They take *keys*, not records as initialization parameters.
2. **Static** (e.g. the view is refreshed by a parent view with an automatically refreshing view model). They are stored as normal `let` variables in the view.

### Example (parent) Automatically Refreshing View Model
```swift
@Published var foos = [Foo]()

init(database: AppDatabase) {
    self.database = database
}

func bind() {
    cancellable = database.fooPublisher(in: database).assign(to: \.foos, on: self)
}

func unbind() {
    cancellable?.cancel()
}
```
and possibly also
```swift
func fooDetailViewModel(foo: Foo) -> FooDetailViewModel {
    // foo passed by key/id -> automatically refreshing. should be stored as @StateObject -> initialized only once
    FooDetailViewModel(database: database, fooID: foo.id!) 
}

func fooSubViewModel(foo: Foo) -> FooSubViewModel {
    // foo passed by value -> static. should be stored as let in the subview -> recreated everytime
    FooSubViewModel(database: database, foo: foo)
}
```
See: `WorkoutListViewModel`

### Example (detail) Automatically Refreshing View Model
```swift
@Published var foo: Foo?

init(database: AppDatabase, fooID: Int64) {
    self.database = database
}

func bind() {
    cancellable = database.fooDetailPublisher(in: database, fooID: fooID).assign(to: \.foo, on: self)
}

func unbind() {
    cancellable?.cancel()
}
```
See:  `WorkoutDetailViewModel`,  `WorkoutExerciseDetailViewModel`

### Example Static View Model
Stored in a `let` constant, is *not* an `ObservableObject`, does *not* observe the data. Instead, a new instance of this view model is created by a parent automatically refreshing view model once `foo` changes!
Otherwise it has the usual view model responsibilities, i.e. processing the data for the view and providing functions to modify the data.

```swift
init(database: AppDatabase, foo: Foo) {
    self.database = database
    self.foo = foo
}
```

Use case: the main view has an automatically refreshing view model for `foo` and creates many static view models for it's subviews that also need to read / modify the values of `foo`. However only the automatically refreshing view model is observing changes to `foo` and will recreate the static view models when needed.

See `WorkoutSetCellViewModel`

### Summary
Usually every "screen"/"navigation view page" has *one automatically refreshing view model* that loads all needed records; and *any number of static view models* that get their records directly from the automatic refreshing view model.


Automatically refreshed view models should subscribe to changes in `View.onAppear()` and unsubscribe in `View.onDisappear()`, such that we don't have so many `ValueObservation`s running at once. This doesn't work well with `@ObservedObject`, because in this case the view model can be recreated at any time, but `View.onAppear()` will only be called once, thus leaving us with an unsubscribed view model! `@StateObject` solves this problem, by only initializing the view model once (and only just before `View.body` is called). Another solution would be to load the data and subscribe to changes in `ViewModel.init()`, but in this case we are doing a lot of unnecessary database fetches and we are keeping many subscriptions open (think of the detail views in a `List`).
