//
//  MenuBarViewModel.swift
//  MacMenuApp
//
//  Created by Attila Szél on 2022. 04. 06..
//

import Foundation
import Combine
import SwiftUI
import MusicPlayer

class MenuBarViewModel: ObservableObject {
    @Published private(set) var text: String
    
    private let subscriptions = Set<AnyCancellable>()
    
    private var musicPlayerManager: MusicPlayerManager?
    
    init(text: String = "") {
        self.text = text
    }
    
    public func setupMusicPlayer(_ player: MusicPlayerManager) {
        self.musicPlayerManager = player
    }
    
    public func updateView() {
        let artist = musicPlayerManager?.currentPlayer?.currentTrack?.artist ?? "ID"
        let title = musicPlayerManager?.currentPlayer?.currentTrack?.title ?? "ID"
        self.text = artist + " - " + title
    }
}
