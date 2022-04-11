//
//  PopoutViewModel.swift
//  NPMenuBar
//
//  Created by Attila Szél on 2022. 04. 11..
//

import Foundation
import MusicPlayer
import SwiftUI


class PopoutViewModel: ObservableObject {
    
    private let musicPlayerManager: MusicPlayerManager
    private let artworkLoader: ArtworkLoader = ArtworkLoader()
    
    var artist: String = ""
    var songName: String = ""
    @Published var artwork: Image?
 
    init() {
        musicPlayerManager = MusicPlayerManager()
        musicPlayerManager.add(musicPlayer: .spotify)
        
        musicPlayerManager.delegate = self
        
        self.updateView()
    }
    
    private func updateView() {
        guard let artist = musicPlayerManager.currentPlayer?.currentTrack?.artist,
              let songName = musicPlayerManager.currentPlayer?.currentTrack?.title,
              let artwork = musicPlayerManager.currentPlayer?.currentTrack?.artworkUrl
        else {
            self.artist = ""
            self.songName = ""
            self.artwork = nil
            return
        }
        
        self.artist = artist
        self.songName = songName
        
        artworkLoader.loadArtwork(artworkUrl: artwork) { image in
            DispatchQueue.main.async {
                self.artwork = image
            }
        }
    }
    
}

extension PopoutViewModel: MusicPlayerManagerDelegate {
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
