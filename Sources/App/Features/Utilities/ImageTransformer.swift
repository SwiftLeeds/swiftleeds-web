//
//  ImageTransformer.swift
//  
//
//  Created by Alex Logan on 05/08/2022.
//

import Foundation
import Vapor

enum ImageTransformer {
    static func transform(imageURL: String) -> String {
        guard !imageURL.contains(bucketName) else {
            return imageURL
        }
        // Hard code region for now
        return "https://\(bucketName).s3.eu-west-2.amazonaws.com/\(imageURL)"
    }
}

extension ImageTransformer {
    static let bucketName: String = Environment.get("S3_BUCKET_NAME")!
}
