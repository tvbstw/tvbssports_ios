//
//  SearchVC.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/21.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import MJRefresh

class SearchVC: UIViewController {

    private var searchBar:UISearchBar!
    var searchHeader: MJRefreshGifHeader!
    var searchVC:UISearchController!
    var searchStr:String = ""
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.backgroundColor
        self.setupSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //FA 開啟搜尋頁
        Util.shared.setAnalyticsLogEnvent(event: FaEvent.show_screen.rawValue, action: "Search Page", label: "開啟_搜尋")
    }
    
    func setupSearchBar() {

        ///SearchController
        self.searchVC = UISearchController(searchResultsController: nil)
        self.searchVC.searchResultsUpdater = self
        self.searchVC.delegate = self
        self.searchVC.searchBar.delegate = self
        self.searchVC.dimsBackgroundDuringPresentation = false
        
        self.searchVC.hidesNavigationBarDuringPresentation = false
        self.searchVC.searchBar.returnKeyType = .search
        self.searchVC.searchBar.placeholder = "請搜尋你感興趣的內容"
        
        self.searchVC.searchBar.backgroundImage = UIImage()
        self.searchVC.searchBar.barTintColor = .white
        //Customize searchbar
        let searchTextField = self.searchVC.searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField != nil {
            searchTextField?.font = UIFont.systemFont(ofSize: 16.0)
            searchTextField?.backgroundColor = UIColor.white
            searchTextField?.textColor = UIColor.lightGray
            searchTextField?.tintColor =  UIColor.lightGray
            if #available(iOS 11.0, *) {
                searchTextField?.layer.cornerRadius = 18.0
            } else {
                searchTextField?.layer.cornerRadius = 14.0
            }
            let leftView = UIImageView(image: UIImage(named: "search_icon"))
            leftView.bounds =  CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
            searchTextField?.leftView = leftView
            searchTextField?.layer.masksToBounds = true
        }
        
        (UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])).tintColor = UIColor.white
        (UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])).setTitleTextAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16.0)], for: .normal)
        self.navigationItem.titleView = self.searchVC.searchBar
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
    }
    
    func setupKeyboard() {
          let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: CGFloat(SCREEN_WIDTH), height: 50))
          let cancelBtn = UIBarButtonItem.init(title: "隱藏", style: .plain, target: self, action: #selector(dismissKeyboard))
          cancelBtn.tintColor = UIColor.black
        toolbar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace , target: self, action: nil),cancelBtn]
          self.searchVC.searchBar.inputAccessoryView = toolbar
      }
    
    func setRefresh() {
        //下拉更新
        self.searchHeader = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.searchHeader.backgroundColor = UIColor.backgroundColor
        self.searchHeader.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .idle)
        self.searchHeader.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .pulling)
        self.searchHeader.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .refreshing)
        self.searchHeader.stateLabel?.isHidden = true
        self.searchHeader.lastUpdatedTimeLabel?.isHidden = true
        self.tableView?.mj_header = self.searchHeader
    }
  
  // MARK:redirect
     @objc func refresh() {

     }
    
    @objc func dismissKeyboard() {
        self.searchStr = self.searchVC.searchBar.text!
        self.searchVC.isActive = false
        self.searchVC.searchBar.text = self.searchStr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = self.searchStr
        navigationItem.backBarButtonItem = backItem
        let vc = segue.destination as? SearchTabVC
        vc?.searchStr = self.searchStr
        vc?.hidesBottomBarWhenPushed = true
        
        /*
        if (segue.identifier == segueIdentify.searchContent ) {
            let vc = segue.destination as? SupertasteSearchContentVC
            vc?.hidesBottomBarWhenPushed = true
            let backItem = UIBarButtonItem()
            ///先判斷sender是否是SupertasteKeyData
            ///因為AUTOList 歷史搜尋 自行輸入只傳搜尋字串
            guard let keydata = sender as? SupertasteKeyData else {
                if let str = sender as? String {
                    backItem.title = str
                    navigationItem.backBarButtonItem = backItem
                    vc?.searchStr =  str
                }
                return
            }
            
            ///點選熱搜會需要傳TYPE所以直接傳SupertasteKeyData
            vc?.keyData = keydata
            backItem.title = keydata.keyword
            navigationItem.backBarButtonItem = backItem
            vc?.searchStr =  keydata.keyword
            vc?.apiUrl = keydata.url
        }
    }
    */
    }
    
    
//SearchVC END
}



extension SearchVC:UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: UISearchControllerDelegate
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    // MARK: SearchHeaderCellDelegate
    func SearchHeaderCellDelBtnClick() {
    }
}


extension SearchVC: UISearchBarDelegate {

    // MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchStr = searchText
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if #available(iOS 11.0, *) {
            searchBar.showsScopeBar = true
        }
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if #available(iOS 11.0, *) {
            searchBar.showsScopeBar = false
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchVC.searchBar.endEditing(true)
        //FA 輸入關鍵字
        if let uwSearchText = searchBar.text {
            Util.shared.setSearchAnalyticsLogEnvent(searchItem:"\(uwSearchText)_輸入關鍵字")
        }

        let vc = SearchListVC()
        vc.keyword = searchBar.text ?? ""
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        // self.performSegue(withIdentifier: segueIdentify.searchContent, sender: title)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
