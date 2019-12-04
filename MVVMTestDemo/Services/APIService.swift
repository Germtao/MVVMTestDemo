//
//  APIService.swift
//  MVVMTestDemo
//
//  Created by QDSG on 2019/12/3.
//  Copyright © 2019 unitTao. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    case noNetwork = "无网络"
    case serverOverload = "服务器超载"
    case permissionDenied = "您没有权限"
}

protocol APIServiceProtocol {
    func fetchPhoto(completion: @escaping (Bool, [Photo], APIError?) -> Void)
}

class APIService: APIServiceProtocol {
    func fetchPhoto(completion: @escaping (Bool, [Photo], APIError?) -> Void) {
        DispatchQueue.global().async {
            sleep(3)
            let path = Bundle.main.path(forResource: "Content", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try! decoder.decode(Photos.self, from: data)
            completion(true, photos.photos, nil)
        }
    }
}
