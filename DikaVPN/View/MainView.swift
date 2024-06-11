//
//  MainView.swift
//  DikaVPN
//
//  Created by Said Tapaev on 13.05.2024.
//
import SwiftUI

struct MainContentView: View {
    @ObservedObject var viewModel = VPNViewModel()
    @State private var showingSecondView = false
    @Binding var isSignedIn: Bool
    @State private var canToggleVPN = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isVPNEnabled {
                    Image("endPlanet")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 1.12)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        
                
                } else {
                    Image("startPlanet")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 1.12)
                        
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        self.showingSecondView.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.white)
                            .imageScale(.large)
                            .padding()
                    }
                    Spacer()
                }

                Spacer()

                HStack {
                    Text(viewModel.isTogglingVPN ? "• Подключение" : (viewModel.isVPNEnabled ? "• Не подключен" : "• Подключен"))
                        .padding(.bottom, 60)
                        .padding()
                        .foregroundColor(viewModel.isVPNEnabled ? .gray : .white)
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                }
                .background(
                    Rectangle()
                        .fill(viewModel.isVPNEnabled ? Color.gray : Color.white)
                        .frame(height: 2.5)
                )
                .padding(.top, 5)
                
                HStack {
                    Button(action: {
                        guard canToggleVPN else { return }
                        canToggleVPN = false
                        Task {
                            await viewModel.toggleVPN()
                            try await Task.sleep(nanoseconds: 2_000_000_000)
                            canToggleVPN = true
                        }
                    }) {
                        Text(viewModel.isVPNEnabled ? "Включить VPN" : "Выключить VPN")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(height: 50)
                    )
                    .padding()
                }
            }
            .sheet(isPresented: $showingSecondView) {
                SecondView()
            }
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    @State static var isSignedIn = false
    static var previews: some View {
        MainContentView(isSignedIn: $isSignedIn)
    }
}
