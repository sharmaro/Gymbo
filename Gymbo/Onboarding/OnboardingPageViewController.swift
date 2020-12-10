//
//  OnboardingPageViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class OnboardingPageViewController: UIPageViewController {
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemGreen
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private var pages = [OnboardingViewController]()
    private var pageIndex = 0
}

// MARK: - UIViewController Var/Funcs
extension OnboardingPageViewController {
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
extension OnboardingPageViewController: ViewAdding {
    func addViews() {
        view.add(subviews: [pageControl])
    }

    func setupViews() {
        dataSource = self
        delegate = self

        pages = OnboardingPage.allCases.map {
            OnboardingViewController($0)
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
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? OnboardingViewController,
            let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        return index == 0 ? nil : pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? OnboardingViewController,
            let index = pages.firstIndex(of: viewController) else {
            return nil
        }

        return index == pages.count - 1 ? nil : pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first as? OnboardingViewController,
            let index = pages.firstIndex(of: viewController) else {
            return
        }
        pageControl.currentPage = index
    }
}
