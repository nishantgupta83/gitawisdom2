//
//  AppIntent.swift
//  GitaWisdomWidget
//
//  Created by Nishant Gupta on 8/26/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "GitaWisdom Configuration" }
    static var description: IntentDescription { "Configure your daily Gita wisdom display." }

    @Parameter(title: "Widget Size", default: "medium")
    var widgetSize: String
}
