//
//  MenuBarView.swift
//  NPMenuBar
//
//  Created by Attila Szél on 2022. 04. 06..
//

import SwiftUI

struct MenuBarView: View {
    
    @ObservedObject var viewModel: MenuBarViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.iconName)
            Label(viewModel.text, systemImage: "")
                .labelStyle(.titleOnly)
        }
        .padding(.vertical)
    }
}
