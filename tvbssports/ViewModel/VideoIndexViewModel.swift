//
//  VideoIndexViewModel.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/19.
//  Copyright © 2021 Eddie. All rights reserved.
//

import Foundation
import CocoaLumberjack

struct VideoIndexRequest: TVBSRequest {
    typealias TVBSResponse = VideoIndex
    var urlPath: String
    var parameters: [String:Any]?
}

struct MarqueeRequest: TVBSRequest {
    typealias TVBSResponse = Marquee
    var urlPath: String
    var parameters: [String:Any]?
}

class VideoIndexViewModel {
    
    private var cellViewModels: [VideoIndex] = [VideoIndex]() {
        didSet {
            //debugPrint(cellViewModels)
            self.reloadTableViewClosure?(behavior, indexPaths)
        }
    }
    
    private var marqueeModels: Marquee? {
        didSet {
            self.checkMarqueeClosure?(marqueeModels)
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var nextPage: String = ""
    
    private var behavior: VCBehavior = .refresh
    private var indexPaths: [IndexPath] = []
    
    var reloadTableViewClosure: ((_ behavior:VCBehavior, _ indexPath: [IndexPath])->())?
    var updateLoadingStatus: (()->())?
    var checkMarqueeClosure:((Marquee?) -> Void)?
    
    init() { }
    
    func dataFetch(_ url: String = VIDEO_INDEX_API, _ behavior: VCBehavior = .refresh) {
        self.behavior = behavior
        self.isLoading = true
        DDLogInfo("url:\(url)")
        VideoIndexRequest(urlPath: url).fetchDataForArray {[weak self] result in
            switch result {
            case .success(let viData):
                self?.processFetched(viData)
            case .failure(let apiError):
                switch apiError {
                case .noNetwork:
                    let arr = [["type":"apiStatus","data":[["status":W_UNREACHABLE]]] as [String : Any]] as [Any]
                    self?.processFetched(arr)
                case .responseEmpty:
                    let arr = [["type":"apiStatus","data":[["status":W_EMPTY]]] as [String : Any]] as [Any]
                    self?.processFetched(arr)
                default:
                    let arr = [["type":"apiStatus","data":[["status":W_ERROR]]] as [String : Any]] as [Any]
                    self?.processFetched(arr)
                }
            }
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> VideoIndex {
        return cellViewModels[indexPath.row]
    }
    
    private func processFetched(_ data: [Any]) {
        DDLogInfo("\(self.behavior.rawValue)")
        var vms = [VideoIndex]()
        _ = data.map({[weak self] in
            if var vi = $0 as? VideoIndex {
                if vi.type == "nextPage" {
                    guard let nextPageString = vi.nextPageData?.first?.nextPage else {
                        vi.cellLayout = .noMoreData
                        vms.append(vi)
                        DDLogInfo("NextPage is nil.")
                        return
                    }
                    
                    if nextPageString == "" {
                        vi.cellLayout = .noMoreData
                        vms.append(vi)
                        DDLogInfo("NextPage is empty.")
                        return
                    }
                    
                    self?.nextPage = "\(VIDEO_INDEX_API)/\(nextPageString)"
                } else if vi.type == "picturelist" {
                    if let endCellData = PictureList(JSON: ["name":PICTURE_LIST_END_CELL]) {
                        vi.pictureData?.append(endCellData)
                        vms.append(vi)
                    }
                } else {
                    vms.append(vi)
                }
            }
            
            if let item = $0 as? [String:Any] {
                if let vi = VideoIndex(JSON: item) {
                    vms.append(vi)
                }
            }
        })
        switch behavior {
        case .refresh:
            indexPaths.removeAll()
            cellViewModels = vms
            toCheckUpCategorylistAndUpdate(vms: vms)
        case .loadMore:
            indexPaths.removeAll()
            let initialIndex = cellViewModels.count
            for index in 0..<vms.count {
                let indexPath = IndexPath(item: initialIndex + index, section: 0)
                indexPaths.append(indexPath)
            }
            //debugPrint("indexPaths:\(indexPaths)")
            cellViewModels.append(contentsOf: vms)
        }
    }
    
}

extension VideoIndexViewModel {
    
    private func toCheckUpCategorylistAndUpdate(vms: [VideoIndex]) {
        let categories: [CategoryData]
        let index = vms.firstIndex(where: { $0.isCategorylist})
        
        categories = index == nil ? [] : (vms[index!].categoryData ?? [])
        updateMenus(categories)
    }
    
    private func updateMenus(_ categories: [CategoryData]) {
        SM.menuArr = categories.map { $0.menu }
    }
}

extension VideoIndexViewModel {

    func dataFetchforMarquee(_ url: String = MARQUEE_API) {
        MarqueeRequest(urlPath: url).fetchDataForObject {[weak self] result in
            switch result {
            case .success(let responseData):
                self?.marqueeModels = responseData
            case .failure(let apiError):
                self?.marqueeModels = nil
                DDLogError(apiError)
            }
        }
    }
}
