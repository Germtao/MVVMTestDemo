//
//  PhotoListViewModelTests.swift
//  MVVMTestDemoTests
//
//  Created by QDSG on 2019/12/4.
//  Copyright © 2019 unitTao. All rights reserved.
//

import XCTest
@testable import MVVMTestDemo

class PhotoListViewModelTests: XCTestCase {
    
    var viewModel: PhotoListViewModel!
    var mockService: MockApiService!

    override func setUp() {
        super.setUp()
        mockService = MockApiService()
        viewModel = PhotoListViewModel(apiService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func test_fetch_photo() {
        mockService.completePhotos = [Photo]()
        viewModel.fetchPhoto()
        XCTAssert(mockService.isFetchPhotoCalled)
    }
    
    func test_fetch_photo_fail() {
        let error = APIError.permissionDenied
        viewModel.fetchPhoto()
        mockService.fetchFailure(error: error)
        XCTAssertEqual(viewModel.alertMsg, error.rawValue)
    }
    
    func test_create_cell_view_mdoel() {
        let photos = DataDecoder().decodingData()
        mockService.completePhotos = photos
        let expect = XCTestExpectation(description: "reload closure triggered")
        viewModel.reloadTableViewClosure = {
            expect.fulfill()
        }
        
        viewModel.fetchPhoto()
        mockService.fetchSuccess()
        
        XCTAssertEqual(viewModel.numberOfRows, photos.count)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_loading_when_fetch() {
        var loadingStatus = false
        let expect = XCTestExpectation(description: "loading status updated")
        viewModel.updateLoadingStatus = { [weak viewModel] in
            loadingStatus = viewModel!.isLoading
            expect.fulfill()
        }
        
        viewModel.fetchPhoto()
        
        XCTAssertTrue(loadingStatus)
        mockService.fetchSuccess()
        XCTAssertFalse(loadingStatus)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_user_press_for_sale_cell() {
        let indexPath = IndexPath(row: 0, section: 0)
        goToFetchPhotoFinished()
        
        viewModel.userPressed(at: indexPath)
        
        XCTAssertTrue(viewModel.isAllowSegue)
        XCTAssertNotNil(viewModel.selectedCellVM)
    }
    
    func test_user_press_not_for_sale_cell() {
        let indexPath = IndexPath(row: 3, section: 0)
        goToFetchPhotoFinished()
        
        let expect = XCTestExpectation(description: "alert message is shown")
        viewModel.showAlertClosure = { [weak viewModel] in
            expect.fulfill()
            XCTAssertEqual(viewModel!.alertMsg, "此产品不出售")
        }
        
        viewModel.userPressed(at: indexPath)
        
        XCTAssertFalse(viewModel.isAllowSegue)
        XCTAssertNil(viewModel.selectedCellVM)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_get_cell_view_model() {
        goToFetchPhotoFinished()
        
        let indexPath = IndexPath(row: 0, section: 0)
        let testPhoto = mockService.completePhotos[indexPath.row]
        
        let cellVM = viewModel.cellViewModel(at: indexPath)
        
        XCTAssertEqual(cellVM.title, testPhoto.name)
    }
    
    func test_cell_view_model() {
        let date = Date()
        let photo = Photo(id: 1, name: "name", description: "desc", created_at: date, image_url: "url", for_sale: true, camera: "camera")
        let photoWithoutCamera = Photo(id: 1, name: "name", description: "desc", created_at: date, image_url: "url", for_sale: true, camera: nil)
        let photoWithoutDesc = Photo(id: 1, name: "name", description: nil, created_at: date, image_url: "url", for_sale: true, camera: "camera")
        let photoWithoutCameraAndDesc = Photo(id: 1, name: "name", description: nil, created_at: date, image_url: "url", for_sale: true, camera: nil)
        
        let cellViewModel = PhotoListCellViewModel(photo: photo)
        let cellViewModelWithoutCamera = PhotoListCellViewModel(photo: photoWithoutCamera)
        let cellViewModelWithoutDesc = PhotoListCellViewModel(photo: photoWithoutDesc)
        let cellViewModelWithoutCameraAndDesc = PhotoListCellViewModel(photo: photoWithoutCameraAndDesc)
        
        XCTAssertEqual(cellViewModel.title, photo.name)
        XCTAssertEqual(cellViewModel.imageUrl, photo.image_url)
        
        XCTAssertEqual(cellViewModel.description, "\(photo.camera!) - \(photo.description!)")
        XCTAssertEqual(cellViewModelWithoutDesc.description, photoWithoutDesc.camera!)
        XCTAssertEqual(cellViewModelWithoutCamera.description, photoWithoutCamera.description!)
        XCTAssertEqual(cellViewModelWithoutCameraAndDesc.description, "")
        
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        
        XCTAssertEqual(cellViewModel.dateText, String(format: "%d-%02d-%02d", year, month, day))
    }

}

extension PhotoListViewModelTests {
    private func goToFetchPhotoFinished() {
        mockService.completePhotos = DataDecoder().decodingData()
        viewModel.fetchPhoto()
        mockService.fetchSuccess()
    }
}

class MockApiService: APIServiceProtocol {
    var isFetchPhotoCalled = false
    
    var completePhotos = [Photo]()
    var completeClosure: ((Bool, [Photo], APIError?) -> Void)!
    
    func fetchPhoto(completion: @escaping (Bool, [Photo], APIError?) -> Void) {
        isFetchPhotoCalled = true
        completeClosure = completion
    }
    
    func fetchSuccess() {
        completeClosure(true, completePhotos, nil)
    }
    
    func fetchFailure(error: APIError?) {
        completeClosure(false, completePhotos, error)
    }
}

class DataDecoder {
    func decodingData() -> [Photo] {
        let path = Bundle.main.path(forResource: "Content", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let photos = try! decoder.decode(Photos.self, from: data)
        return photos.photos
    }
}
