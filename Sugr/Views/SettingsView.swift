//
//  SettingsView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 27.12.24.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject              var model : SugrModel
    
    @State var nightscoutUrl       : String = Properties.instance.nightscoutUrl!
    @State var nightscoutToken     : String = Properties.instance.nightscoutToken!
    @State var nightscoutApiSecret : String = Properties.instance.nightscoutApiSecret!
    @State var nightscoutApiV2     : Bool   = Properties.instance.nightscoutApiV2!
    @State var unitMgDl            : Bool   = Properties.instance.unitMgDl!
    
    private let fontSize : CGFloat = 14
    
    
    var body: some View {
        return Form {
            Section(header: Text("Settings").bold()) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Spacer()
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundStyle(.primary)
                        .buttonStyle(.plain)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    Text("Nightscout URL")
                        .font(.system(size: self.fontSize)).bold()
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    TextField("Nightscout URL", text: $nightscoutUrl)
                        .font(.system(size: self.fontSize))
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    Text("API Secret")
                        .font(.system(size: self.fontSize)).bold()
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    SecureField("API Secret", text: $nightscoutApiSecret)
                        .font(.system(size: self.fontSize))
                        .disableAutocorrection(true)
                    
                    Text("Token")
                        .font(.system(size: self.fontSize)).bold()
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    SecureField("API Token", text: $nightscoutToken)
                        .font(.system(size: self.fontSize))
                        .disableAutocorrection(true)
                    Toggle(nightscoutApiV2 ? "API V2" : "API V1", isOn: $nightscoutApiV2)
                        .font(.system(size: self.fontSize))
                        .toggleStyle(ToggleStyle1())
                }
                                
                VStack(alignment: .leading, spacing: 5) {
                    Group {
                        // Unit mg/dl
                        Toggle(unitMgDl ? "mg/dl" : "mmol/L", isOn: $unitMgDl)
                            .font(.system(size: self.fontSize))
                            .toggleStyle(ToggleStyle1())
                            .onChange(of: unitMgDl) { ov, nv in
                                Properties.instance.unitMgDl = self.unitMgDl
                            }
                    }
                }
            }
            .onAppear {
                self.nightscoutUrl       = Properties.instance.nightscoutUrl!
                self.nightscoutToken     = Properties.instance.nightscoutToken!
                self.nightscoutApiSecret = Properties.instance.nightscoutApiSecret!
                self.nightscoutApiV2     = Properties.instance.nightscoutApiV2!
                self.unitMgDl            = Properties.instance.unitMgDl!
            }
            .onDisappear {
                Properties.instance.nightscoutUrl       = self.nightscoutUrl
                Properties.instance.nightscoutToken     = self.nightscoutToken
                Properties.instance.nightscoutApiSecret = self.nightscoutApiSecret
                Properties.instance.nightscoutApiV2     = self.nightscoutApiV2
                Properties.instance.unitMgDl            = self.unitMgDl
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

struct ToggleStyle1: ToggleStyle {
    #if os(iOS)
    let width : CGFloat = 40
    let height: CGFloat = 40 / 1.5
    #else
    let width : CGFloat = 38
    let height: CGFloat = 38 / 1.5
    #endif
    
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: height)
                    .frame(width: width, height: height)
                    .foregroundColor(configuration.isOn ? .accentColor : Color.gray.opacity(0.25))
                
                RoundedRectangle(cornerRadius: height)
                    .frame(width: height - 4, height: height - 4)
                    .padding(2)
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            configuration.$isOn.wrappedValue.toggle()
                        }
                }
            }
            
            configuration.label
        }
        .accessibility(activationPoint: configuration.isOn ? UnitPoint(x: 0.3, y: 0.5) : UnitPoint(x: 0.7, y: 0.5))
    }
}

struct ToggleStyle2: ToggleStyle {
    #if os(iOS)
    let width : CGFloat = 40
    let height: CGFloat = 40 / 1.5
    #else
    let width : CGFloat = 38
    let height: CGFloat = 38 / 1.5
    #endif
    
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label

            #if os(iOS)
                //Spacer()
            #endif
            
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: height)
                    .frame(width: width, height: height)
                    .foregroundColor(configuration.isOn ? .accentColor : Color.gray.opacity(0.25))
                
                RoundedRectangle(cornerRadius: height)
                    .frame(width: height - 4, height: height - 4)
                    .padding(2)
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            configuration.$isOn.wrappedValue.toggle()
                        }
                }
            }
        }
        .accessibility(activationPoint: configuration.isOn ? UnitPoint(x: 0.3, y: 0.5) : UnitPoint(x: 0.7, y: 0.5))
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
