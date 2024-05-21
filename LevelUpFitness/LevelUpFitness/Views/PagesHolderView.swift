//
//  PagesHolderView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI

struct PagesHolderView: View {
    @State var pageType: PageType
    
    var body: some View {
        switch pageType {
        case .home:
            HomeView()
        case .workout:
            Text("Workout")
        case .profile:
            Text("Workout")
        }
    }
}

#Preview {
    PagesHolderView(pageType: .home)
}
