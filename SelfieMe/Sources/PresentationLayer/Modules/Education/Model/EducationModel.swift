//
//  EducationModel.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 19.05.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


protocol EducationModelDataSource {
    
    func educationModelNumberOfStages(_ model: EducationModel) -> Int
    
    func educationModel(_ model: EducationModel, stageForIndex: Int) -> EducationStage?
    
    func educationModel(_ model: EducationModel, actionForSegueForStageIndex: Int) -> EducationAction?
    
    func educationModel(_ model: EducationModel, stageChanged: EducationStage)
    
    func educationModel(_ model: EducationModel, educationEnded: Bool)
    
}


class EducationModel {
    
    var dataSource: EducationModelDataSource?
    
    var currentIndex: Int! {
        didSet {
            if let stage = dataSource?.educationModel(self, stageForIndex: currentIndex) {
                dataSource?.educationModel(self, stageChanged: stage)
                if let stagesCount = dataSource?.educationModelNumberOfStages(self) {
                    let isEnd = currentIndex == stagesCount
                    dataSource?.educationModel(self, educationEnded: isEnd)
                } else {
                    dataSource?.educationModel(self, educationEnded: true)
                }
            } else {
                dataSource?.educationModel(self, educationEnded: true)
            }
        }
    }
    
    
    func start() {
        currentIndex = 0
    }
    
    func commitAction(_ action: EducationAction) {
        if let currentAction = dataSource?.educationModel(self, actionForSegueForStageIndex: currentIndex) {
            if currentAction == action {
                currentIndex? += 1
            }
        } else {
            dataSource?.educationModel(self, educationEnded: true)
        }
    }
    
    
//    func getCurrentStage() -> EducationStage? {
//        return dataSource?.educationModel(self, stageForIndex: currentIndex)
//    }
    
}



struct EducationStage {

    let message: String
    let sourceView: UIView
    let containerView: UIView
    let arrowDirection: AMPopTipDirection
    
}


struct EducationAction: Equatable {

    let id: Int

}

func ==(lhs: EducationAction, rhs: EducationAction) -> Bool {
    return lhs.id == rhs.id
}
