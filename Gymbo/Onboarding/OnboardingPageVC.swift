//
//  OnboardingPageVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class OnboardingPageVC: UIPageViewController {
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemGreen
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private var pages = [OnboardingVC]()
    private var pageIndex = 0
}

// MARK: - UIViewController Var/Funcs
extension OnboardingPageVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        User.firstTimeLoadComplete()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension OnboardingPageVC: ViewAdding {
    func addViews() {
        view.add(subviews: [pageControl])
    }

    func setupViews() {
        dataSource = self
        delegate = self

        pages = OnboardingPage.allCases.map {
            OnboardingVC($0)
        }
        setViewControllers([pages[pageIndex]], direction: .forward, animated: true)

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = pageIndex
    }

    func setupColors() {
        view.backgroundColor = .dynamicWhite
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -10)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingVC,
              let index = pages.firstIndex(of: vc) else {
            return nil
        }
        return index == 0 ? nil : pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingVC,
              let index = pages.firstIndex(of: vc) else {
            return nil
        }

        return index == pages.count - 1 ? nil : pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let vc = pageViewController.viewControllers?.first as? OnboardingVC,
              let index = pages.firstIndex(of: vc) else {
            return
        }
        pageControl.currentPage = index
    }
}
