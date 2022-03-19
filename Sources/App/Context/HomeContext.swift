//
//  HomeContext.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor

struct HomeContext: Content {
    var speakers: [Speaker] = Speaker.speakers
}
