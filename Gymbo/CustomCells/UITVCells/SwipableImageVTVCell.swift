//
//  SwipableImageVTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SwipableImageVTVCell: RoundedTVCell {
    private let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension SwipableImageVTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SwipableImageVTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [horizontalScrollView, pageControl])
    }

    func setupViews() {
        horizontalScrollView.delegate = self
    }

    func setupColors() {
        pageControl.currentPageIndicatorTintColor = .systemBlue
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            horizontalScrollView.top.constraint(equalTo: roundedView.top),
            horizontalScrollView.leading.constraint(equalTo: roundedView.leading),
            horizontalScrollView.trailing.constraint(equalTo: roundedView.trailing),
            horizontalScrollView.bottom.constraint(equalTo: pageControl.top),

            pageControl.leading.constraint(equalTo: roundedView.leading),
            pageControl.trailing.constraint(equalTo: roundedView.trailing),
            pageControl.bottom.constraint(equalTo: roundedView.bottom),
            pageControl.height.constraint(equalToConstant: 20)
        ])
        horizontalScrollView.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension SwipableImageVTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(imageFileNames: [String]?, isUserMade: Bool) {
        guard let imageFileNames = imageFileNames else {
            return
        }

        pageControl.numberOfPages = imageFileNames.count
        horizontalScrollView.contentSize.width = (frame.width - 40) *
            CGFloat(imageFileNames.count)

        let directory: Directory = isUserMade ? .userImages : .exercises
        let imageViewSize = CGSize(width: frame.width - 40,
                                   height: frame.height - 30)
        for (index, fileName) in imageFileNames.enumerated() {
            if let image = Utility.getImageFrom(name: fileName,
                                                directory: directory) {
                let origin = CGPoint(x: (frame.width - 40) * CGFloat(index),
                                     y: 10)
                let frame = CGRect(origin: origin, size: imageViewSize)
                let imageView = UIImageView(frame: frame)
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                imageView.layoutIfNeeded()
                horizontalScrollView.addSubview(imageView)
            }
        }
        horizontalScrollView.layoutIfNeeded()
    }
}

// MARK: -
extension SwipableImageVTVCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
