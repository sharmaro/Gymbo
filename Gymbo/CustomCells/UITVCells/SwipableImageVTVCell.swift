//
//  SwipableImageVTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SwipableImageVTVCell: UITableViewCell {
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
        pageControl.alpha = 0.5
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
        contentView.add(subviews: [horizontalScrollView, pageControl])
    }

    func setupViews() {
        horizontalScrollView.delegate = self
    }

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        pageControl.pageIndicatorTintColor = .dynamicDarkGray
        pageControl.currentPageIndicatorTintColor = .systemBlue
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            horizontalScrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            horizontalScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            horizontalScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            horizontalScrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor),

            pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
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
        horizontalScrollView.contentSize.width = frame.width * CGFloat(imageFileNames.count)

        let directory: Directory = isUserMade ? .userImages : .exercises
        for (index, fileName) in imageFileNames.enumerated() {
            if let image = Utility.getImageFrom(name: fileName,
                                                directory: directory) {
                let imageView = UIImageView(frame: CGRect(origin:
                    CGPoint(x: frame.width * CGFloat(index),
                            y: 0), size:
                    CGSize(width: frame.width,
                           height: frame.height - 20)))
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
