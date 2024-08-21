//
//  SampleActivity.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

import GroupActivities

/// グループアクティビティに関するメタデータ
struct SampleActivity: GroupActivity {
    // アクティビティについて説明する情報の提供
    var metadata: GroupActivityMetadata {
        var data = GroupActivityMetadata()
        data.title = "Sample App"
        data.type = .generic
        return data
    }
}
