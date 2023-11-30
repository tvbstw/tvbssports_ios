//
//  FAInterface.swift
//  videoCollection
//
//  Created by Woody on 2022/4/13.
//  Copyright © 2022 Eddie. All rights reserved.
//

protocol FAParametersInterface {
    var event: String { get }
    var action: String { get }
    var label: String { get }
}

extension Util {
    func setAnalytics(item: FAParametersInterface) {
        setAnalyticsLogEnvent(event: item.event, action: item.action, label: item.label)
    }
}
