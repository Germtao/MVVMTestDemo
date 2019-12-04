//
//  PhotoListViewModel.swift
//  MVVMTestDemo
//
//  Created by QDSG on 2019/12/3.
//  Copyright © 2019 unitTao. All rights reserved.
//

import Foundation

class PhotoListViewModel {
    let apiService: APIServiceProtocol
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    
    var alertMsg: String? {
        didSet {
            showAlertClosure?()
        }
    }
    
    var isAllowSegue: Bool = false
    
    var selectedCellVM: PhotoListCellViewModel?
    
    var reloadTableViewClosure: (() -> Void)?
    var showAlertClosure: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?
    
    private var photos = [Photo]()
    
    private var cellViewModels = [PhotoListCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var numberOfRows: Int {
        return cellViewModels.count
    }
    
    func cellViewModel(at indexPath: IndexPath) -> PhotoListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
}

extension PhotoListViewModel {
    func fetchPhoto() {
        isLoading = true
        apiService.fetchPhoto { [weak self] (success, photos, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMsg = error.rawValue
            } else {
                self?.processPhoto(photos: photos)
            }
        }
    }
    
    // 处理图片
    private func processPhoto(photos: [Photo]) {
        self.photos = photos
        var vms = [PhotoListCellViewModel]()
        photos.forEach { photo in
            vms.append(PhotoListCellViewModel(photo: photo))
        }
        
        cellViewModels = vms
    }
    
    func userPressed(at indexPath: IndexPath) {
        let cellVM = cellViewModels[indexPath.row]
        if cellVM.forSale {
            isAllowSegue = true
            selectedCellVM = cellVM
        } else {
            isAllowSegue = false
            selectedCellVM = nil
            alertMsg = "此产品不出售"
        }
    }
}

struct PhotoListCellViewModel {
    let photo: Photo
    
    var title: String {
        return photo.name
    }
    
    var description: String {
        var descTextContainer = [String]()
        if let camera = photo.camera {
            descTextContainer.append(camera)
        }
        if let description = photo.description {
            descTextContainer.append( description )
        }
        return descTextContainer.joined(separator: " - ")
    }
    
    var imageUrl: String {
        return photo.image_url
    }
    
    var dateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: photo.created_at)
    }
    
    var forSale: Bool {
        return photo.for_sale
    }
}
