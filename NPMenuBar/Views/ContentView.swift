//
//  ContentView.swift
//  NPMenuBar
//
//  Created by Attila Szél on 2022. 04. 05..
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: PopoutViewModel = PopoutViewModel()
    
    @State var hover: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                if viewModel.artwork != nil {
                    ZStack(alignment: .top) {
                        viewModel.artwork!
                            .blur(radius: hover ? 10 : 0)
                        
                        if hover {
                            VStack {
                                Text(viewModel.artist + " - " + viewModel.songName)
                                    .font(.title3)
                                    .padding()
                            }
                        }
                    }
                } else {
                    Image(systemName: "play.slash.fill")
                        .resizable()
                }
            }
            .onHover { hover in
                self.hover = hover
            }
        }
    }
}

