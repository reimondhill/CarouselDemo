//
//  ViewController.swift
//  CarouselDemo
//
//  Created by Ramon Haro Marques on 05/06/2020.
//  Copyright © 2020 Ramon Haro Marques. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    let colors: [UIColor] = [
        UIColor(red: 19.0/255.0, green: 51.0/255.0, blue: 76.0/255.0, alpha: 1.0),
        UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 46.0/255.0, alpha: 1.0),
        UIColor(red: 253.0/255.0, green: 95.0/255.0, blue: 0.0/255.0, alpha: 1.0),
        UIColor(red: 55.0/255.0, green: 35.0/255.0, blue: 120.0/255.0, alpha: 1.0)
    ]
    
    //let emojis: [String] = ["👑", "🙈", "👾"]
    
    
    //MARK: UI
    private lazy var contentView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var collectionView: CarouselCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        
        let view = CarouselCollectionView(frame: .zero, collectionViewFlowLayout: flowLayout)
    
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isAutoscrollEnabled = true
        view.autoScrollTime = 3.0
        //view.showsVerticalScrollIndicator = false
        //view.showsHorizontalScrollIndicator = false
        view.decelerationRate = UIScrollView.DecelerationRate.fast
        
        view.register(CVCell.self, forCellWithReuseIdentifier:"CVCell")
        view.dataSource = self
        view.delegate = self
        //view.carouselDataSource = self
        
        return view
    }()
    
    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        
        view.numberOfPages = colors.count
        view.tintColor = .black
        
        return view
    }()
    
    private lazy var bottomView: AButton = {
        let view = AButton()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
        
        return view
    }()
    
    
    //MARK: - Constructor
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: - Lifecycle methods
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard collectionView.frame != .zero else { return }
        //collectionView.flowLayout.itemSize = .init(width: collectionView.frame.width - 100, height: collectionView.frame.height)
        collectionView.reloadData()
    }
    
}


//MARK: - Private methods
private extension ViewController {
    
    func setupUI() {
        view.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        contentView.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        //collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        //view.addSubview(pageControl)
        
        contentView.addSubview(bottomView)
        bottomView.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }

}

//MARK: - CarouselCollectionView methods
//MARK: CarouselCollectionViewDataSource implementation
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! CVCell
        
        cell.backgroundColor = colors[indexPath.row]
        
        return cell
    }
    
    
}

//MARK: CarouselCollectionViewDataSource implementation
extension ViewController: UICollectionViewDelegate {
    
}

//MARK: CarouselCollectionViewDataSource implementation
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return .init(width: (collectionView.frame.height) * (16/9),
                     height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 50
    }
    
}
