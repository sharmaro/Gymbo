//
//  SwipableImageViewTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SwipableImageViewTableViewCell: UITableViewCell {
    private var horizontalScrollView = UIScrollView()
    private var pageControl = UIPageControl()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ReuseIdentifying
extension SwipableImageViewTableViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension SwipableImageViewTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [horizontalScrollView, pageControl])
    }

    func setupViews() {
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.showsHorizontalScrollIndicator = false
        horizontalScrollView.showsVerticalScrollIndicator = false
        horizontalScrollView.delegate = self

        pageControl.currentPage = 0
        pageControl.alpha = 0.5
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .systemBlue
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            horizontalScrollView.topAnchor.constraint(equalTo: topAnchor),
            horizontalScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalScrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor)
        ])
        horizontalScrollView.layoutIfNeeded()

        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}

// MARK: - Funcs
extension SwipableImageViewTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(imagesData: [Data]?) {
        guard let imagesData = imagesData else {
            return
        }

        pageControl.numberOfPages = imagesData.count
        horizontalScrollView.contentSize.width = frame.width * CGFloat(imagesData.count)

        for (index, data) in imagesData.enumerated() {
            if let image = UIImage(data: data) {
                let imageView = UIImageView(frame: CGRect(origin:
                    CGPoint(x: frame.width * CGFloat(index),
                            y: 0),size:
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
extension SwipableImageViewTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
