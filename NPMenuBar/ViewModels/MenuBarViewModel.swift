//
//  MenuBarViewModel.swift
//  NPMenuBar
//
//  Created by Attila Szél on 2022. 04. 06..
//

import Foundation
import SwiftUI
import MusicPlayer

class MenuBarViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var text: String
    @Published private(set) var iconName: String
    
    private var musicPlayerManager: MusicPlayerManager
    
    init(text: String = "", image: String = "headphones.circle") {
        self.text = text
        self.iconName = image
        
        musicPlayerManager = MusicPlayerManager()
        musicPlayerManager.add(musicPlayer: .spotify)
        
        musicPlayerManager.delegate = self
        
        self.updateView()
    }
    
    // MARK: - Functions
    
    private func updateView() {
        // Be sure that we have both
        guard let artist = musicPlayerManager.currentPlayer?.currentTrack?.artist,
              let title = musicPlayerManager.currentPlayer?.currentTrack?.title
        else {
            self.text = "NPMenuBar"
            self.iconName = "headphones.circle"
            return
        }
        
        self.iconName = "headphones.circle.fill"
        self.text = artist + " - " + title
    }
}

// MARK: - MusicPlayerManagerDelegate functions

extension MenuBarViewModel: MusicPlayerManagerDelegate {
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval) {
        self.updateView()
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition position: TimeInterval) {
        self.updateView()
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidQuit player: MusicPlayer) {
        self.updateView()
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer) {
        self.updateView()
    }
    
}
