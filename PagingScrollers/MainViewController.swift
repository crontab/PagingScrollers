//
//  MainViewController.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 13/02/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit



class MainViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	private var scrollers: [UIScrollView] {
		viewControllers?.map({ $0.view as! UIScrollView }) ?? []
	}


	// MARK: --


	private lazy var pages: [UIViewController] = {
		[
			storyboard!.instantiateViewController(identifier: "Left"),
			storyboard!.instantiateViewController(identifier: "Right")
		]
	}()


	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
	}


	// MARK: - UIPageViewControllerDataSource -

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index > 0 else {
			return nil
		}
		return pages[index - 1]
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
			return nil
		}
		return pages[index + 1]
	}


	// MARK: - UIPageViewControllerDelegate -
}

