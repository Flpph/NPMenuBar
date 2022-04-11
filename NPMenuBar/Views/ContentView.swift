//
//  ContentView.swift
//  NPMenuBar
//
//  Created by Attila Szél on 2022. 04. 05..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "headphones")
                .resizable()
            
            Divider()
            
            Button("Quit") {
                NSApp.terminate(self)
            }
        }
    }
}

