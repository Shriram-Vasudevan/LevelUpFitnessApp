//
//  HomeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HStack {
                    Text("LevelUp Fitness")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Today's Video")
                        .font(.custom("EtruscoNowCondensed Bold", size: 25))
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.white)
                        .frame(width: .infinity, height: 200)
                        .overlay (
                            Image("GuyAtTheGym")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            
                                .padding(.horizontal)
                                .clipped()
                        )
                    
                    HStack {
                       VStack {
                           HStack {
                               Text("Leg Exercises")
                                   .font(.custom("Sailec Bold", size: 23))
                                   .foregroundColor(.black)
                                   .textCase(.uppercase)
                               
                               Spacer()
                               
                           }
                           
                           HStack {
                               Text("Exercises to Strengthen your Legs")
                                   .font(.custom("Sailec Medium", size: 15))
                                   .foregroundColor(.gray)
                               
                               Spacer()
                           }
                       }
                       
                       Spacer()
                       
                       VStack {
                           Text("14")
                               .font(.custom("Sailec Bold", size: 20))
                           
                           Text("MAY")
                               .font(.custom("Sailec Bold", size: 20))
                       }
                   }
                   .padding()
                   .background(
                       Rectangle()
                           .fill(Color(red: 250/255.0, green: 245/255.0, blue: 245/255.0))
                   )
        
                }
                .padding(.horizontal)
                .cornerRadius(3)
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
