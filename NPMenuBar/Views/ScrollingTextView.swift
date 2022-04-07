//
//  ScrollingTextView.swift
//  MacMenuApp
//
//  Created by Attila Szél on 2022. 04. 06..
//

import SwiftUI

struct ScrollingTextView: View {
    
    @ObservedObject var viewModel: MenuBarViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.text)
        }
    }
}

//struct ScrollingTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollingTextView()
//    }
//}
