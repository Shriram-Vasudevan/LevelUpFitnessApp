//
//  LibraryView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var storageManager: StorageManager
    
    @State var selectedExercise: ExerciseLibraryExerciseDownloaded?
    
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack (spacing: 0) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 15)
                        .hidden()
                    
                    Spacer()
                    
                    Text("Exercise Library")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 15)
                }
                .padding(.horizontal)
        
                VStack {
                    ScrollView(.vertical) {
                        ForEach(storageManager.exercises, id: \.id) { exercise in
                            ExerciseLibraryExerciseWidget(exerciseLibraryExercise: exercise)
                                .onTapGesture {
                                    self.selectedExercise = exercise
                                }
                                
                        }
                        
                        HStack {
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .padding(.top)
                .background(
                    Rectangle()
                        .fill(.white)
                )
                .ignoresSafeArea(.all)
            }
        }
        .fullScreenCover(item: $selectedExercise) { exercise in
            FullPageVideoView(videoURL: exercise.videoURL)
        }
    }
}

#Preview {
    LibraryView(storageManager: StorageManager())
}
