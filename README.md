#  GRDB + SwiftUI Example

### Thoughts

There are two types of view models
1. Automatically refreshing (e.g. using ValueObservations + Combine). They are `ObservableObjects` and should be bound to the View's lifecycle by `@StateObject`. They take *keys*, not records as initialization parameters.
2. Static (e.g. the view is refreshed by a parent view with an automatically refreshing view model). They are stored as normal `let` variables in the view.

Usually a "screen"/"navigation view page" has *one automatic refreshing view model* that loads all needed records, and *any number of static view models* that get their records directly from the automatic refreshing view model.

Automatically refreshed view models should subscribe to changes in `View.onAppear()` and unsubscribe in `View.onDisappear()`. This doesn't work well with `@ObservedObject`, because in this case the view model can be recreated at any time, but `View.onAppear()` will only be called once, thus leaving us with an unsubscribed view model! `@StateObject` solves this problem, by only initializing the view model once (and only just before `View.body` is called). Another solution would be to load the data and subscribe to changes in `ViewModel.init()`, but in this case we are doing a lot of unnecessary database fetches and we are keeping many subscriptions open (think of the detail views in a `List`).

### Examples

Examples for automatic refreshing view models: `WorkoutListViewModel`,  `WorkoutDetailViewModel`,  `WorkoutExerciseDetailViewModel`
Example for static view model: `WorkoutSetCellViewModel`
