import SwiftUI

struct LevelInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 240 / 255.0, green: 244 / 255.0, blue: 252 / 255.0)
                .ignoresSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        HStack {
                            Button(action: {
                                dismiss()
                                
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            Spacer()
                        }
                        
                        HStack {
                            Text("Level Up System")
                                .font(.headline)
                        }
                        
                    }
                    .padding(.top, 16)
                    
                    Text("Understanding Your Fitness Journey")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 20)
                    
                    Text("At Level Up, we've developed a unique leveling system to help you track and achieve your fitness goals. This system is based on various factors that contribute to your overall fitness progress.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Primary Sublevels")
                            .font(.headline)
                        
                        HStack {
                            SubLevelCircularWidget(level: 1, image: "Dumbell", name: "Strength")
                                .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                            
                            Spacer()
                            
                            SubLevelCircularWidget(level: 1, image: "Running", name: "Endurance")
                                .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                            
                            Spacer()
                            
                            SubLevelCircularWidget(level: 1, image: "360", name: "Mobility")
                                .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white) 
                        )
                    }
                    .padding(.vertical, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dynamic Leveling")
                            .font(.headline)
                        
                        Text("Your level is dynamic and can change based on your performance:")
                            .font(.subheadline)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .padding(.top, 7)
                            Text("Improve sublevels or maintain consistency to increase your level")
                        }
                        .font(.subheadline)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .padding(.top, 7)
                            Text("Missing workouts or reducing sublevels for multiple weeks may decrease your level")
                        }
                        .font(.subheadline)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .padding(.top, 7)
                            Text("The system uses a large timeframe so a few bad performances won't affect levels drastically")
                        }
                        .font(.subheadline)
                        
                        Text("Our primary goal is to make your level representative of your current form, encouraging continuous improvement and dedication to your fitness journey.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    LevelInfoView()
}

