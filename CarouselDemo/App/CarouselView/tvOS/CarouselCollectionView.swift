//
//  CarouselCollectionView.swift
//  CarouselDemoTV
//
//  Created by Ramon Haro Marques on 06/06/2020.
//  Copyright © 2020 Ramon Haro Marques. All rights reserved.
//

import UIKit

class CarouselCollectionView: UICollectionView {
    //MARK: - Class model
    enum JumpDirection {
        case forward
        case backward
    }
    
    //MARK: - Properties
    //MARK: Protocols
    /// Override dataSource to set up our responder chain
    override weak var dataSource: UICollectionViewDataSource? {
        get {
            return super.dataSource
        }
        set {
            rootDataSource = newValue
            super.dataSource = self
        }
    }
    /// The original data source for the carousel
    private weak var rootDataSource: UICollectionViewDataSource!
    
    /// Override delegate to set up our responder chain
    override weak var delegate: UICollectionViewDelegate? {
        get {
            return super.delegate
        }
        set {
            rootDelegate = newValue as? UICollectionViewDelegateFlowLayout
            super.delegate = self
        }
    }
    /// The original delegate for the carousel
    private weak var rootDelegate: UICollectionViewDelegateFlowLayout?
    
    override var collectionViewLayout: UICollectionViewLayout {
        didSet {
            if !(collectionViewLayout is UICollectionViewFlowLayout) {
                fatalError("CarouselCollectionView can only be used with UICollectionViewFlowLayout instances")
            }
        }
    }
    /// CollectionViewLayout as UICollectionViewFlowLayout
    var collectionViewFlowLayout: UICollectionViewFlowLayout {
        get { return collectionViewLayout as! UICollectionViewFlowLayout }
        set { super.collectionViewLayout = newValue}
    }
    
    //MARK: Functionalities
    override var decelerationRate: UIScrollView.DecelerationRate {
        get { return .fast}
        set {}
    }
    
    override var showsVerticalScrollIndicator: Bool {
        get { return false }
        set {}
    }
    
    override var showsHorizontalScrollIndicator: Bool {
        get { return false }
        set {}
    }
    
    /// Current direction our focus is traveling
    var focusHeading: UIFocusHeading?
    /// Cell to focus on if we update focus
    var manualFocusCell: IndexPath?
    
    /// The index of the item that is currently in focus.
    ///
    /// The layout uses this to know which page to center in the view.
    open internal(set) var currentlyFocusedItem: Int = 0
    /// The index of the item that was in focus when the user began a touch event.
    ///
    /// This is used to determine how far we can advance focus in a single gesture.
    open internal(set) var initiallyFocusedItem: Int?
    
    /// Number of cells to buffer
    private var buffer: Int = 2
    
    /// Cached count of current number of items
    private var count = 0
    
    /// Whether or not we're cued to jump
    private var isJumping = false
    
    
    //MARK: Configuration
    /// The number of cells that are generally focused on the screen.
    ///
    /// Usually the total number of visible is this many + 2, since the edges are showing slices
    /// of the cells before and after.
    ///
    /// This is used to decide both how many cells to add around the core as a buffer for infinite
    /// scrolling as well as how many cells ahead or behind we allow the user to focus at once.
    var itemsPerPage: Int = 1 {
        didSet {
            buffer = itemsPerPage * 2
        }
    }
    
    /// Whether or not to auto-scroll this carousel when the user is not interacting with it.
    var isAutoscrollEnabled: Bool = false
    /// The time in between auto-scroll events.
    var autoScrollTime: Double = 5.0
    /// The timer used to control auto-scroll behavior
    private var scrollTimer: Timer?
    

    //MARK: - Constructor
    init(frame: CGRect, collectionViewFlowLayout: UICollectionViewFlowLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewFlowLayout)
        
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    
    }
    
}


//MARK: - Lifecycle methods
extension CarouselCollectionView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        initiallyFocusedItem = currentlyFocusedItem
        super.touchesBegan(touches, with: event)
    }
    
    override func reloadData() {
        super.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            guard sSelf.count > 0 else {
                return
            }
            sSelf.scrollToItem(sSelf.buffer, animated: false)
            sSelf.setNeedsFocusUpdate()
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard isJumping else { return }
        isJumping = false
        
        if focusHeading == .left {
            jump(.forward)
        }
        else {
            jump(.backward)
        }
        
        currentlyFocusedItem = manualFocusCell!.item
        setNeedsFocusUpdate()
    }

}


//MARK: - private methods
private extension CarouselCollectionView {

    private func setup() {
        if collectionViewFlowLayout.scrollDirection != .horizontal {
            print(self, "WARNING: ", "Vertical scrolling not supported. Changed to horizontal.")
            collectionViewFlowLayout.scrollDirection = .horizontal
        }
        
        object_setClass(collectionViewFlowLayout, Layout.self)
        delegate = self
        dataSource = self
        setNeedsFocusUpdate()
    }

    /// Returns the index path of the root data source item given an index path from this collection
    /// view, which naturally includes the buffer cells.
    func adjustedIndexPathForIndexPath(_ indexPath: IndexPath) -> IndexPath {
//        precondition(count >= buffer, "CarouselCollectionView requires at least twice the number of items per page to work properly. For best results: a number that is evenly divisible by the number of items per page.")
        
        let index = indexPath.item
        let wrapped = (index - buffer < 0) ? (count + (index - buffer)) : (index - buffer)
        let adjustedIndex = wrapped % count
        
        return IndexPath(item: adjustedIndex, section: 0)
    }

    func scrollToItem(_ item: Int, animated: Bool) {
        if let initialOffset = (collectionViewFlowLayout as! Layout).offsetForItemAtIndex(item) {
            setContentOffset(CGPoint(x: initialOffset,y: contentOffset.y), animated: animated)
        }
        
        // Update focus element in case we have it
        currentlyFocusedItem = item
        manualFocusCell = IndexPath(item: currentlyFocusedItem, section: 0)
        setNeedsFocusUpdate()
    }
    
    func jump(_ direction: JumpDirection) {
        let currentOffset = contentOffset.x
        var jumpOffset = CGFloat(count) * (collectionViewFlowLayout as! Layout).totalItemWidth
        
        if case .backward = direction {
            jumpOffset *= -1
        }
        setContentOffset(CGPoint(x: currentOffset + jumpOffset, y: contentOffset.y), animated: false)
    }
    
    //MARK: - Auto Scroll
    func beginAutoScroll() {
        guard isAutoscrollEnabled else {
            return
        }
        
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(timeInterval: autoScrollTime, target: self,
            selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    func stopAutoScroll() {
        scrollTimer?.invalidate()
    }
    
    @objc func scrollToNextPage() {
        var nextItem = currentlyFocusedItem + itemsPerPage
        if nextItem >= buffer + count {
            nextItem -= count
            jump(.backward)
        }

        scrollToItem(nextItem, animated: true)
    }
    
}


//MARK: - UICollectionView methods
//MARK: UICollectionViewDataSource implementation
extension CarouselCollectionView: UICollectionViewDataSource {
    
    // For the empty case, returns 0. For a non-empty data source, returns the original number of cells plus the buffer cells.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        count = rootDataSource.collectionView(collectionView, numberOfItemsInSection: section)
        guard count > 0 else {
            return 0
        }
        
        return count + 2 * buffer
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let adjustedPath = adjustedIndexPathForIndexPath(indexPath)
        
        return rootDataSource.collectionView(collectionView, cellForItemAt: adjustedPath)
    }
    
}

//MARK: UICollectionViewDelegate implementation
extension CarouselCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        // Allow users to leave
        guard let nextFocusedIndexPath = context.nextFocusedIndexPath else {
            beginAutoScroll()
            return true
        }
        
        // Allow users to enter
        guard context.previouslyFocusedIndexPath != nil else {
            stopAutoScroll()
            return true
        }
        
        // Restrict movement to a page at a time if we're swiping, but don't break
        // keyboard access in simulator.
        if initiallyFocusedItem != nil && abs(nextFocusedIndexPath.item - initiallyFocusedItem!) > itemsPerPage {
            return false
        }
        
        focusHeading = context.focusHeading
        currentlyFocusedItem = nextFocusedIndexPath.item
        
        if focusHeading == .left && nextFocusedIndexPath.item < buffer {
            isJumping = true
            currentlyFocusedItem += count
        }
        
        if focusHeading == .right && nextFocusedIndexPath.item >= buffer + count {
            isJumping = true
            currentlyFocusedItem -= count
        }
        
        manualFocusCell = IndexPath(item: currentlyFocusedItem, section: 0)
        return true
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return manualFocusCell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout implementation
extension CarouselCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = rootDelegate?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) {
            collectionViewFlowLayout.itemSize = size
            return size
        }
        else {
            return collectionViewFlowLayout.itemSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let edges = rootDelegate?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) {
            collectionViewFlowLayout.sectionInset = edges
            return edges
        }
        else {
            return collectionViewFlowLayout.sectionInset
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let minimumLineSpacing = rootDelegate?.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) {
            collectionViewFlowLayout.minimumLineSpacing = minimumLineSpacing
            return minimumLineSpacing
        }
        else {
            return collectionViewFlowLayout.minimumLineSpacing
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let minimumInteritemSpacing = rootDelegate?.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) {
            collectionViewFlowLayout.minimumInteritemSpacing = minimumInteritemSpacing
            return minimumInteritemSpacing
        }
        else {
            return collectionViewFlowLayout.minimumInteritemSpacing
        }
    }
    
}


//MARK: - Layout
extension CarouselCollectionView {
   
    class Layout: UICollectionViewFlowLayout {
        var totalItemWidth: CGFloat {
            return itemSize.width + minimumLineSpacing
        }
        
        var carousel: CarouselCollectionView {
            guard let carousel = collectionView as? CarouselCollectionView else {
                fatalError("This layout should only be used by CarouselCollectionView instances")
            }
            return carousel
        }
        
        func offsetForItemAtIndex(_ index: Int) -> CGFloat? {
            let pageSize = carousel.itemsPerPage
            let pageIndex = (index / pageSize)
            let firstItemOnPageIndex = pageIndex * pageSize
            let firstItemOnPage = IndexPath(item: firstItemOnPageIndex, section: 0)
            
            guard let cellAttributes = layoutAttributesForItem(at: firstItemOnPage) else {
                return nil
            }
            
            let offset = ((carousel.frame.size.width - (CGFloat(pageSize) * totalItemWidth) - minimumLineSpacing) / 2.0) + minimumLineSpacing
            return cellAttributes.frame.origin.x - offset
        }
        
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            
            guard let offset = offsetForItemAtIndex(carousel.currentlyFocusedItem) else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            }
            return CGPoint(x: offset, y: proposedContentOffset.y)
        }
    }
    
}
