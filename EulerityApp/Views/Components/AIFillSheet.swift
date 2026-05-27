//
//  AIFillSheet.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//

import SwiftUI

struct AIFillSheet: View {

    @ObservedObject var vm: FormViewModel
    @Binding var isPresented: Bool

    let presets: [(emoji: String, title: String, subtitle: String, fill: () -> Void)]

    init(vm: FormViewModel, isPresented: Binding<Bool>) {
        self.vm = vm
        self._isPresented = isPresented

        presets = [
            (
                "🍕", "Local Restaurant Chain",
                "Food brand · Meta + Google · $200/day",
                {
                    vm.values["campaign_name"]    = "Taste the Difference"
                    vm.values["target_locations"] = "Chicago, IL · New York, NY"
                    vm.values["daily_budget"]     = "200"
                    vm.values["campaign_url"]     = "https://tasteit.com/offer"
                    vm.values["campaign_notes"]   = "Target hungry college students within 3 miles. Warm, fun tone."
                    vm.multiValues["ad_networks"] = ["net_meta", "net_google"]
                    vm.multiValues["campaign_goal"] = ["goal_foottraffic"]
                    vm.toggleValues["enable_ai_optimize"] = true
                }
            ),
            (
                "👗", "Fashion & Apparel",
                "Retail brand · Meta + TikTok · $350/day",
                {
                    vm.values["campaign_name"]    = "Summer Drop 2026"
                    vm.values["target_locations"] = "Los Angeles, CA · Miami, FL"
                    vm.values["daily_budget"]     = "350"
                    vm.values["campaign_url"]     = "https://brand.com/summer"
                    vm.values["campaign_notes"]   = "Young women 18–30. Aesthetic, trendy visuals. Urgency-driven copy."
                    vm.multiValues["ad_networks"] = ["net_meta", "net_tiktok"]
                    vm.multiValues["campaign_goal"] = ["goal_conversions"]
                    vm.toggleValues["enable_retargeting"] = true
                }
            ),
            (
                "🏋️", "Fitness Studio",
                "Local gym · Google + YouTube · $150/day",
                {
                    vm.values["campaign_name"]    = "New Year. New You."
                    vm.values["target_locations"] = "Austin, TX"
                    vm.values["daily_budget"]     = "150"
                    vm.values["campaign_url"]     = "https://fitlife.com/join"
                    vm.values["campaign_notes"]   = "Motivational tone. Push free trial offer. Target 25–45 age group."
                    vm.multiValues["ad_networks"] = ["net_google", "net_youtube"]
                    vm.multiValues["campaign_goal"] = ["goal_leads"]
                    vm.toggleValues["enable_retargeting"] = true
                    vm.toggleValues["enable_ai_optimize"] = true
                }
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.purple)
                Text("AI Quick Fill")
                    .font(.title3.weight(.semibold))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Text("Pick a campaign type and we'll fill the form for you.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            VStack(spacing: 12) {
                ForEach(presets.indices, id: \.self) { i in
                    let p = presets[i]
                    Button {
                        p.fill()
                        isPresented = false
                    } label: {
                        HStack(spacing: 14) {
                            Text(p.emoji)
                                .font(.largeTitle)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(p.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text(p.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.purple.opacity(0.7))
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(20)

            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}
