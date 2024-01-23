//
//  MessageItem.swift
//  DiffableDataSourceSample
//
//  Created by sdk on 23.01.2024.
//

import UIKit

enum Owner {
    case own, generated
}

struct MessageItem: Hashable {
    let id = UUID()
    var owner: Owner
    var text: String
}
