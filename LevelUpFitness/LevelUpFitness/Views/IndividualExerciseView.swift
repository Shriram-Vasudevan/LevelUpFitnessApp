//
//  IndividualExerciseView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/8/24.
//

import SwiftUI
import AVKit

struct IndividualExerciseView: View {
    var exercise: ExerciseLibraryExercise
    
    @State private var avPlayer = AVPlayer()
    @Environment(\.dismiss) var dismiss

    @State var videoURL: URL?
    var body: some View {
        ZStack {
            Color(red: 240 / 255.0, green: 244 / 255.0, blue: 252 / 255.0)
                .ignoresSafeArea(.all)
            
            VStack (spacing: 0){
                ZStack
                {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }

                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Exercise")
                        .font(.custom("Sailec Bold", size: 20))
                        .foregroundColor(.black)
                }
                .padding(.bottom)
                
                if let videoURL = self.videoURL {
                    VideoPlayer(player: avPlayer)
                        .aspectRatio(16/9, contentMode: .fit)
                        .onAppear {
                            avPlayer = AVPlayer(url: videoURL)
                            avPlayer.play()
                        }
                } else {
                    Text("Retrieving Video")
                }
                
                ScrollView(.vertical) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.custom("Sailec Bold", size: 25))
                                .fontWeight(.bold)
                            Text("Body Area: \(exercise.bodyArea)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    
                    }
                    
                }
                .padding([.top, .horizontal])
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            guard let cdnURL = URL(string: exercise.cdnURL) else { return }
            LocalStorageUtility.downloadVideoAndSaveToTempFile(url: cdnURL, completion: { result in
                switch result {
                    case .success(let localURL):
                        self.videoURL = localURL
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            })
        }
    }
}

#Preview {
    IndividualExerciseView(exercise: ExerciseLibraryExercise(
        id: "", cdnURL: "",
        name: "Bicep Curl",
        description: "Perform a classic bicep curl with proper form. Stand with feet shoulder-width apart, holding dumbbells at your sides with palms facing forward. Keeping your upper arms stationary, curl the weights up to shoulder level while contracting your biceps.",
        bodyArea: "Arms", level: 1
    ))
}
