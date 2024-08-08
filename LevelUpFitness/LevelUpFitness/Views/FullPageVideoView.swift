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
    
    @State var videoURL: URL
    
    @State var avPlayer = AVPlayer()
    
    var body: some View {
        ZStack {
            VideoPlayer(player: avPlayer)
                .onAppear {
                    avPlayer = AVPlayer(url: videoURL)
                    avPlayer.play()
                }
        }
    }
}

#Preview {
    FullPageVideoView(videoURL: URL(string: "Test")!)
}
