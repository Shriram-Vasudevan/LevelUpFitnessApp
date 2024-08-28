//
//  FullPageVideoView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import SwiftUI
import AVFoundation
import AVKit

struct FullPageVideoView: View {
    var cdnURL: String
    
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
                        .aspectRatio(9/16, contentMode: .fit)
                        .onAppear {
                            avPlayer = AVPlayer(url: videoURL)
                            avPlayer.play()
                            
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                                avPlayer.seek(to: .zero)
                                avPlayer.play()
                           }
                        }
                } else {
                    Text("Retrieving Video")
                }
                
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            guard let cdnURL = URL(string: cdnURL) else { return }
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
    FullPageVideoView(cdnURL: "", videoURL: URL(string: "Test")!)
}
