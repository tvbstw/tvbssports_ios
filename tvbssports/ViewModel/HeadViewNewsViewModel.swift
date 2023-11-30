//
//  HeadViewNewsViewModel.swift
//  videoCollection
//
//  Created by darren on 2021/12/7.
//  Copyright © 2021 leon. All rights reserved.
//

import UIKit

class HeadViewNewsViewModel: NSObject {

    private(set) var HeadlineNewsList : [HeadlineNews]?{
        didSet {
            self.bindHeadViewNewsViewModelToController()
        }
    }
    
    var bindHeadViewNewsViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        queryData()
    }
    
    func queryData() {
        HeadlineM.shared.getHeadlineNewsList { (result) in
            switch result {
            case .success(let list):
                self.HeadlineNewsList = list
            case .failure(let error):
                print("HeadlineNews error\(error.description)")
            }
        }
    }
    
}
