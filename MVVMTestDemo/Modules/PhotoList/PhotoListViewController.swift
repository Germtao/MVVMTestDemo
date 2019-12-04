//
//  PhotoListViewController.swift
//  MVVMTestDemo
//
//  Created by QDSG on 2019/12/4.
//  Copyright © 2019 unitTao. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var viewModel = PhotoListViewModel()

}

extension PhotoListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initViewModel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoDetailViewController,
            let cellVM = viewModel.selectedCellVM {
            vc.imageUrl = cellVM.imageUrl
        }
    }
}

// MARK: - 初始化
private extension PhotoListViewController {
    func initUI() {
        navigationItem.title = "图片列表"
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func initViewModel() {
        viewModel.showAlertClosure = { [weak self] in
            if let message = self?.viewModel.alertMsg {
                self?.showAlert(message)
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                let loading = self?.viewModel.isLoading ?? false
                if loading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self?.tableView.alpha = 0.0
                    }
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self?.tableView.alpha = 1.0
                    }
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.fetchPhoto()
    }
}

// MARK: - Helper Method
private extension PhotoListViewController {
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension PhotoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoListViewCell.reuseIdentifier,
                                                       for: indexPath) as? PhotoListViewCell else { return UITableViewCell() }
        
        let cellVM = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellVM)
        return cell
    }
}

extension PhotoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        viewModel.userPressed(at: indexPath)
        if viewModel.isAllowSegue {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
