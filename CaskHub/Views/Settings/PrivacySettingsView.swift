//
//  PrivacySettingsView.swift
//  CaskHub
//
//  Created by Ali Elsokary on 04/10/2026.
//

import SwiftUI

struct PrivacySettingsView: View {
    @AppStorage(Analytics.enabledKey) private var analyticsEnabled = true
    @AppStorage(CrashReporter.enabledKey) private var crashReportingEnabled = true

    var body: some View {
        Form {
            Section("Usage Analytics") {
                Toggle(
                    "Share anonymous usage analytics",
                    isOn: $analyticsEnabled
                )

                Text(.settingsPrivacyUsageAnalytics)
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            Section("Crash Reports") {
                Toggle(
                    "Share crash reports",
                    isOn: $crashReportingEnabled
                )

                Text(.settingsPrivacyCrashReports)
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .applyingPrivacyChanges(analytics: analyticsEnabled, crashReports: crashReportingEnabled)
    }
}

extension View {
    func applyingPrivacyChanges(analytics: Bool, crashReports: Bool) -> some View {
        onChange(of: analytics) { _, isOn in
            Analytics.refresh()
            if isOn { Analytics.analyticsReEnabled() }
        }
        .onChange(of: crashReports) { _, _ in
            CrashReporter.refresh()
        }
    }
}
