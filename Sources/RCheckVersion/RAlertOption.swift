//
//  File.swift
//  
//
//  Created by Ray on 2019/12/24.
//

import Foundation

/// 彈跳訊息文字
public class RAlertOption {
    private(set) var alertTitle: String = "發現新版本"
    private(set) var nextTimeTitle: String = "下次提醒"
    private(set) var confirmTitle: String = "前往更新"
    private(set) var showNextType: [RCheckVersion.UpdateType] = []
    private(set) var nextUpdateAction: (() -> Void)?
    private(set) var sameVersionAction: (() -> Void)?
    
    /// 設定 Alert 是否顯示下次更新
    /// - Parameter showNextVersion: 哪些版本更新需要顯示下次更新
    public init(showNextVersion type: RCheckVersion.UpdateType...) {
        self.showNextType = type
    }
    
    /// 設定 Alert Title
    /// - Parameter title: 標題
    public func set(title: String) {
        self.alertTitle = title
    }
    
    /// 設定 Alert 下次更新的文字
    /// - Parameter next: 按鈕文字
    public func set(next: String)  {
        self.nextTimeTitle = next
    }
    
    /// 設定 Alert 前往更新的文字
    /// - Parameter goTo: 按鈕文字
    public func set(goTo: String) {
        self.confirmTitle = goTo
    }
    
    /// 下次更新
    public func nextUpdate(action: @escaping (() -> Void)) {
        self.nextUpdateAction = action
    }
    
    /// 不須更新時
    public func sameVersion(action: @escaping (() -> Void)) {
        self.sameVersionAction = action
    }
}
