//
//  ViewController.swift
//  Debounce Throttle
//
//  Created by dbug on 2/23/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController {

    @IBOutlet weak var draggableView: UIView!
    
    let disposeBag = DisposeBag()
    
    var change = BehaviorRelay<Int>(value: 0)
    
    var regular = BehaviorRelay<Int>(value: 0)
    var debounce = BehaviorRelay<Int>(value: 0)
    var throttle = BehaviorRelay<Int>(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let panGesture = draggableView.rx
            .panGesture()
            .share(replay: 1)
        
        panGesture
            .when(.began, .changed)
            .asTranslation()
            .subscribe(onNext: { translation, _ in
                self.draggableView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                self.change.accept(self.change.value+1)
            })
            .disposed(by: disposeBag)
        

//        change.subscribe(onNext: { change in
//            print("\(change)")
//        })
//        .disposed(by: disposeBag)
        
        change
            .throttle(.microseconds(10_0000), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [self] change in
                throttle.accept(throttle.value+1)
        })
        .disposed(by: disposeBag)
        
        change
            .debounce(.microseconds(0), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [self] change in
                debounce.accept(debounce.value+1)
            })
            .disposed(by: disposeBag)
        
    }


}

