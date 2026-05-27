//
//  DynamicFormView.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/26/26.
//

import SwiftUI

struct FormView: View {

    @StateObject private var vm = FormViewModel()
    @FocusState private var focusedField: String?
    @State private var showAISheet = false

    var body: some View {
        NavigationStack {
            if let payload = vm.payload {
                let theme = payload.theme
                let fields = payload.fields.sorted(by: { $0.order < $1.order })

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {

                            ForEach(fields) { field in
                                fieldView(field: field, theme: theme, allFields: fields)
                                    .id(field.id)
                            }

                            Button {
                                focusedField = nil
                                vm.submit()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        if let id = vm.firstErrorFieldId {
                                            proxy.scrollTo(id, anchor: .center)
                                        }
                                    }
                                }
                            } label: {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#2563EB") ?? .blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .contentShape(Rectangle())
                            .padding(.top, 8)
                        }
                        .padding()
                    }
                }
                .background(Color(hex: theme.backgroundColor) ?? .white)
                .navigationTitle(payload.formTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAISheet = true
                        } label: {
                            Label("AI Fill", systemImage: "wand.and.stars")
                        }
                    }
                }
                .sheet(isPresented: $showAISheet) {
                    AIFillSheet(vm: vm, isPresented: $showAISheet)
                }
                .fullScreenCover(isPresented: $vm.showSuccess) {
                    SuccessView(
                        payload: vm.payload!,
                        values: vm.values,
                        multiValues: vm.multiValues,
                        toggleValues: vm.toggleValues,
                        isPresented: $vm.showSuccess
                    )
                }
                .onChange(of: vm.showSuccess) { isShowing in
                    if !isShowing {
                        vm.loadForm()
                    }
                }

            } else {
                ProgressView("Loading...")
            }
        }
    }

    @ViewBuilder
    func fieldView(field: FormField, theme: FormTheme, allFields: [FormField]) -> some View {
        switch field.type {
        case .text:
            TextInputView(
                field: field,
                theme: theme,
                vm: vm,
                focusedField: $focusedField,
                nextFieldId: nextTextFieldId(after: field, in: allFields)
            )
        case .dropdown:
            DropdownView(field: field, theme: theme, vm: vm)
        case .toggle:
            ToggleView(field: field, theme: theme, vm: vm)
        case .checkbox:
            CheckboxView(field: field, theme: theme, vm: vm)
        case .unknown:
            EmptyView()
        }
    }

    func nextTextFieldId(after current: FormField, in fields: [FormField]) -> String? {
        let textFields = fields.filter { $0.type == .text }
        guard let index = textFields.firstIndex(where: { $0.id == current.id }),
              index + 1 < textFields.count
        else { return nil }
        return textFields[index + 1].id
    }
}
