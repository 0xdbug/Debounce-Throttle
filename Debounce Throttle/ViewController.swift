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
    
    var currentBarIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareStackViews()
        setupGesture()
        setupEventSubscriptions()
    }
    
    func setupEventSubscriptions() {
        event.subscribe(onNext: { [self] _ in
            regularStack.arrangedSubviews[currentBarIndex].backgroundColor = .red
        })
        .disposed(by: disposeBag)
        
        event
            .debounce(.microseconds(50000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [self] _ in
                debounceStack.arrangedSubviews[currentBarIndex].backgroundColor = .red
            })
            .disposed(by: disposeBag)
        
        event
            .throttle(.microseconds(50000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [self] _ in
                throttleStack.arrangedSubviews[currentBarIndex].backgroundColor = .red
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
        for _ in 0..<30 {
            let view = UIView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            
            superview.addArrangedSubview(view)
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalTo: superview.heightAnchor),
                view.widthAnchor.constraint(equalToConstant: 2)
            ])
        }
    }
    
    func clearStack(stack: UIStackView) {
        for view in stack.arrangedSubviews {
            view.backgroundColor = .clear
        }
    }
    
    func handleCounts() {
        if currentBarIndex >= 29 {
            currentBarIndex = 0
            clearStack(stack: regularStack)
            clearStack(stack: debounceStack)
            clearStack(stack: throttleStack)
        } else {
            currentBarIndex += 1
        }
    }
}
