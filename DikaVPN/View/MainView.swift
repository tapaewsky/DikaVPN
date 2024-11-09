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
        ZStack {
            backgroundImage
            content
        }
        .sheet(isPresented: $showingSecondView) {
            SecondView()
        }
    }

   
    private var backgroundImage: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isVPNEnabled {
                    Image("endPlanetBang")
                        .resizable()
                        .scaledToFill()  // Заполняет весь экран, обрезая края если нужно
                        .frame(width: geometry.size.width/*, height: geometry.size.height*/)
                        .ignoresSafeArea()  // Игнорируем безопасные зоны
                        .transition(.opacity)
                } else {
                    Image("startPlanetBang")
                        .resizable()
                        .scaledToFill()  // Заполняет весь экран, обрезая края если нужно
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()  // Игнорируем безопасные зоны
                        .transition(.opacity)
                }
            }
        }
    }

  
    private var content: some View {
        VStack {
            topBar
            Spacer()
            connectionStatus
            vpnToggleButton
        }
    }

   
    private var topBar: some View {
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
    }

   
    private var connectionStatus: some View {
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
    }

   
    private var vpnToggleButton: some View {
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
}

struct MainContentView_Previews: PreviewProvider {
    @State static var isSignedIn = false
    static var previews: some View {
        MainContentView(isSignedIn: $isSignedIn)
    }
}
