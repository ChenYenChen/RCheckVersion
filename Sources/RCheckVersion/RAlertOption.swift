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
    
    
    /// 設定 Alert Title
    /// - Parameter title: 標題
    public func set(title: String) -> Self {
        self.alertTitle = title
        return self
    }
    
    /// 設定 Alert 下次更新的文字
    /// - Parameter next: 按鈕文字 ， 設定空字串將顯示強制更版
    public func set(next: String) -> Self {
        self.nextTimeTitle = next
        return self
    }
    
    /// 設定 Alert 前往更新的文字
    /// - Parameter goTo: 按鈕文字
    public func set(goTo: String) -> Self {
        self.confirmTitle = goTo
        return self
    }
}
