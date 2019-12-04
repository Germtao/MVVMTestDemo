//
//  Photo.swift
//  MVVMTestDemo
//
//  Created by QDSG on 2019/12/3.
//  Copyright © 2019 unitTao. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos: [Photo]
}

struct Photo: Codable {
    let id: Int
    let name: String
    let description: String?
    let created_at: Date
    let image_url: String
    let for_sale: Bool
    let camera: String?
}
