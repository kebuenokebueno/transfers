//
//  AmountEditor.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

import SwiftUI


struct AmountEditor: View {
    @Binding var amount: String
    
    var body: some View {
        HStack {
            Text("Amount")
            Spacer()
            TextField("0.00", text: $amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}
