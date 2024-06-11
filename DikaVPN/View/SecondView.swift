//
//  SecondView.swift
//  DikaVpn
//
//  Created by Said Tapaev on 08.04.2024.
//

import SwiftUI

struct SecondView: View {
    @ObservedObject var viewModel = SecondViewModel()
    @State private var showDetailPrivacy = false
    @State private var showDetailAgreement = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Button("Помощь") {
                        viewModel.openTelegram()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .medium))

                    Divider().background(Color.white)
                        .frame(width: 300, height: 2.5, alignment: .center)

                    Button("Конфиденциальность") {
                        showDetailPrivacy.toggle()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .medium))
                    .sheet(isPresented: $showDetailPrivacy) {
                        DetailView(title: "Конфиденциальность", content: """
                        Политика конфиденциальности VPN:
                        
                        1. Сбор информации: Мы собираем минимальное количество информации, необходимое для обеспечения функционирования VPN-сервиса.
                        
                        2. Логирование: Мы не ведем логи активности пользователей, включая их онлайн-действия и данные о посещенных веб-сайтах.
                        
                        3. Персональные данные: Мы не продаем, не обмениваем и не передаем персональные данные наших пользователей третьим лицам.
                        
                        4. Шифрование: Вся передаваемая через наше приложение информация шифруется для защиты конфиденциальности.
                        
                        5. Сохранение данных: Мы не храним данные о сеансах подключения или использования VPN.
                        
                        6. Дополнительная информация: Мы можем собирать анонимные статистические данные для улучшения качества нашего сервиса, но без привязки к конкретным пользователям.
                        """)
                    
                    }

                    Divider().background(Color.white)
                        .frame(width: 300, height: 2.5, alignment: .center)

                    Button("Соглашение") {
                        showDetailAgreement.toggle()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .medium))
                    .sheet(isPresented: $showDetailAgreement) {
                        DetailView(title: "Соглашение", content: """
                        Соглашение об использовании VPN:

                        1. Пользователь соглашается использовать VPN только в законных целях.
                        
                        2. Пользователь обязуется не нарушать права других лиц при использовании VPN.
                        
                        3. Пользователь осознает, что VPN не гарантирует абсолютную анонимность и безопасность.
                        
                        4. Пользователь несет ответственность за безопасность своих учетных данных.
                        
                        5. Пользователь обязуется не использовать VPN для совершения противоправных действий.
                        
                        6. Провайдер VPN оставляет за собой право прекратить предоставление услуг при нарушении пользователем соглашения.
                        """)
                    }
                }
                .padding(.top, -150)
                .padding()
            }
           
        }
    }
}

#Preview {
    SecondView()
        .preferredColorScheme(.light)
}

