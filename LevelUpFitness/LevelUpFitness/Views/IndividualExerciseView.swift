//
//  IndividualExerciseView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/8/24.
//

import SwiftUI
import AVKit

struct IndividualExerciseView: View {
    var progression: Progression
    
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
                            Text(progression.name)
                                .font(.custom("Sailec Bold", size: 25))
                                .fontWeight(.bold)
                            Text("Exercise Type: \(progression.exerciseType)")
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
            guard let cdnURL = URL(string: progression.cdnURL) else { return }
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
    IndividualExerciseView(progression: Progression.preview()!)
}
