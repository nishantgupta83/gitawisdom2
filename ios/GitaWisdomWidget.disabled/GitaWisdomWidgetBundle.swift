//
//  GitaWisdomWidgetBundle.swift
//  GitaWisdomWidget
//
//  Created by Nishant Gupta on 8/26/25.
//

import WidgetKit
import SwiftUI

@main
struct GitaWisdomWidgetBundle: WidgetBundle {
    var body: some Widget {
        GitaWisdomWidget()
        GitaWisdomWidgetControl()
        GitaWisdomWidgetLiveActivity()
    }
}
