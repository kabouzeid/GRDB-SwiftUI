//
//  WorkoutList.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import SwiftUI

struct WorkoutList: View {
    @StateObject var viewModel: WorkoutListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.workouts) { workout in
                NavigationLink(destination: self.workoutDetailView(for: workout)) {
                    WorkoutRow(workout: workout)
                }
            }
            .onDelete { offsets in
                self.viewModel.deleteWorkouts(atOffsets: offsets)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(Text("\(viewModel.workouts.count) Workouts"))
        .navigationBarItems(leading: EditButton())
        .onAppear(perform: viewModel.bind)
        .onDisappear(perform: viewModel.unbind)
    }
    
    func workoutDetailView(for workout: Workout) -> some View {
        WorkoutDetailView(viewModel: viewModel.workoutDetailViewModel(workout: workout))
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.title)
                .font(.headline)
            if let comment = workout.comment {
                Text(comment)
                    .foregroundColor(.secondary)
            }
            Text(workout.startDate, style: .date)
                .foregroundColor(.secondary)
        }
    }
}

struct WorkoutList_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutList(viewModel: WorkoutListViewModel(database: .random()))
    }
}
