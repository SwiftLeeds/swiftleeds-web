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
        guard let bucketName = Environment.get("S3_BUCKET_NAME") else {
            fatalError("Missing 'S3_BUCKET_NAME' environment variable")
        }
        
        guard !imageURL.contains(bucketName) else {
            return imageURL
        }
        // Hard code region for now
        return "https://\(bucketName).s3.eu-west-2.amazonaws.com/\(imageURL)"
    }
}
