//
//  AView.swift
//  CarouselDemo
//
//  Created by Ramon Haro Marques on 07/06/2020.
//  Copyright © 2020 Ramon Haro Marques. All rights reserved.
//

import UIKit

class AView: UIView {

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        backgroundColor = context.nextFocusedView == self ? .blue:.red
    }

}

class AButton: UIButton {

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        backgroundColor = context.nextFocusedView == self ? .blue:.red
    }

}
