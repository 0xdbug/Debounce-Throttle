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
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var throttleStack: UIStackView!
    @IBOutlet weak var debounceStack: UIStackView!
    @IBOutlet weak var regularStack: UIStackView!
    
    let event = PublishSubject<Void>()
    
    var regular = 0
    var debounce = 0
    var throttle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareStackViews()
        setupGesture()
        setupEventSubscriptions()
    }
    
    func setupEventSubscriptions() {
        event.subscribe(onNext: { [self] _ in
            if regular < regularStack.arrangedSubviews.count {
                regularStack.arrangedSubviews[regular].isHidden = false
            }
        })
        .disposed(by: disposeBag)
        
        event
            .debounce(.microseconds(50000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [self] _ in
                if debounce < debounceStack.arrangedSubviews.count {
                    debounceStack.arrangedSubviews[debounce].isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        event
            .throttle(.microseconds(50000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [self] _ in
                if throttle < throttleStack.arrangedSubviews.count {
                    throttleStack.arrangedSubviews[throttle].isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupGesture() {
        let panGesture = draggableView.rx
            .panGesture()
            .share(replay: 1)
        
        panGesture
            .when(.began, .changed)
            .asTranslation()
            .subscribe(onNext: { [self] translation, _ in
                draggableView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                
                handleCounts()
                
                event.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func prepareStackViews() {
        prepare(superview: regularStack)
        prepare(superview: debounceStack)
        prepare(superview: throttleStack)
    }
    
    func prepare(superview: UIStackView) {
        for i in 0..<30 {
            let view = UIView()
            view.backgroundColor = .red
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isHidden = true
            
            superview.addArrangedSubview(view)
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalTo: superview.heightAnchor),
                view.widthAnchor.constraint(equalToConstant: 2)
            ])
        }
    }
    
    func clearStack(stack: UIStackView) {
        for view in stack.arrangedSubviews {
            view.isHidden = true
        }
    }
    
    func handleCounts() {
        if regular >= regularStack.arrangedSubviews.count - 1 {
            regular = 0
            clearStack(stack: regularStack)
        } else {
            regular += 1
        }
        
        if debounce >= debounceStack.arrangedSubviews.count - 1 {
            debounce = 0
            clearStack(stack: debounceStack)
        } else {
            debounce += 1
        }
        
        if throttle >= throttleStack.arrangedSubviews.count - 1 {
            throttle = 0
            clearStack(stack: throttleStack)
        } else {
            throttle += 1
        }
    }
}
