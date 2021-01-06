//
//  ViewController.swift
//  01声明式编程
//
//  Created by 华惠友 on 2020/11/27.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let s1 = Student(name: "Jane", scores: [ .chinese: 86, .math: 92, .english: 73, .physics: 88])
    let s2 = Student(name: "Tom", scores: [ .chinese: 99, .math: 52, .english: 97, .physics: 36])
    let s3 = Student(name: "Emma", scores: [ .chinese: 91, .math: 92, .english: 100, .physics: 99])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let students = [s1, s2, s3]
        
        bestStudent(students)
        bestStudent1(students)
    }
    
    ///检查 students 里的学生的平均分，并输出第一名的姓名
    ///指令式编程
    func bestStudent(_ students: [Student]) {
        var best: (Student, Double)?
        for s in students {
            var totalScore = 0
            for key in Subject.allCases {
                totalScore += s.scores[key] ?? 0
            }
            
            let averageSocre = Double(totalScore) / Double(Subject.allCases.count)
            if let temp = best {
                if averageSocre > temp.1 {
                    best = (s, averageSocre)
                }
            } else {
                best = (s, averageSocre)
            }
        }
        
        if let best = best {
            print("最高平均分: \(best.1), 姓名: \(best.0.name)")
        } else {
            print("students 为空")
        }
    }
    
    ///声明式\函数式编程
    ///
    func bestStudent1(_ students: [Student]) {
        if let best = students
            .map({ ($0, average($0.scores)) })
            .sorted(by: { $0.1 > $1.1 }).first {
            print("最高平均分: \(best.1), 姓名: \(best.0.name)")
        } else {
            print("students 为空")
        }
    }
    
    func average(_ scores: [Subject: Int]) -> Double {
        return Double(scores.values.reduce(0, +)) / Double(Subject.allCases.count)
    }
    
}
