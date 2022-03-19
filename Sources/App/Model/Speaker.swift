//
//  Speaker.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor

struct Speaker: Encodable, Content {
    let name: String
    let title: String
    let socialLink: String
    let imageLink: String
}

extension Speaker {
    static let speakers = [taylor, alex, timCook, adam, joe, matt]
    static let taylor = Speaker(
        name: "Taylor Swift",
        title: "Musical Genius.",
        socialLink: "https://twitter.com/taylorswift13",
        imageLink: "https://pbs.twimg.com/profile_images/1405947624184713220/aCLC4bTE_400x400.jpg"
    )
    static let timCook = Speaker(
        name: "Tim Cook",
        title: "Apple guy who did v good things.",
        socialLink: "https://twitter.com/tim_cook",
        imageLink: "https://pbs.twimg.com/profile_images/1403556543098916872/83tVAzyy_400x400.jpg"
    )
    static let alex = Speaker(
        name: "Alex Logan",
        title: "Coffee guy.",
        socialLink: "https://twitter.com/swiftyalex",
        imageLink: "https://pbs.twimg.com/profile_images/1475087054652559361/lgTnY96Q_400x400.jpg"
    )
    static let adam = Speaker(
        name: "Adam Rush",
        title: "Founder of SwiftLeeds.",
        socialLink: "https://twitter.com/Adam9Rush",
        imageLink: "https://pbs.twimg.com/profile_images/1447297821573537799/rwBkje7a_400x400.jpg"
    )
    static let joe = Speaker(
        name: "Adam Rush",
        title: "Swift Guru, who made this site",
        socialLink: "https://twitter.com/jrwilliams_ios/",
        imageLink: "https://pbs.twimg.com/profile_images/1099032873993150465/GlUCW4BR_400x400.jpg"
    )
    static let matt = Speaker(
        name: "Matthew Gallagher",
        title: "Lead Engineer",
        socialLink: "https://twitter.com/pdamonkey",
        imageLink: "https://pbs.twimg.com/profile_images/948206790352736256/5CWJuPdp_400x400.jpg"
    )
}
