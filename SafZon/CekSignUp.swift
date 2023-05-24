//
//  CekSignUp.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI

struct CekSignUp: View {
    @EnvironmentObject private var authModel: AuthViewModel
    var body: some View {
        Group {
        if authModel.user != nil {
        MainView()
        } else {
        SignUpView()
        }
        }.onAppear {
        authModel.listenToAuthState()
        }
    }
}

struct CekSignUp_Previews: PreviewProvider {
    static var previews: some View {
        CekSignUp()
    }
}
