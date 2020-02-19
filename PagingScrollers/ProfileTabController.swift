//
//  ProfileTabController.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 19/02/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit


class ProfileTabController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	private(set) lazy var leftPage = storyboard!.instantiateViewController(withIdentifier: "Left") as! UITableViewController
	private(set) lazy var rightPage = storyboard!.instantiateViewController(withIdentifier: "Right") as! UITableViewController

	private lazy var pages: [UIViewController] = [leftPage, rightPage]

	private(set) lazy var scrollers: [UIScrollView] = pages.map { $0.view as! UIScrollView }

	var scrollerTopInsets: CGFloat? {
		get { scrollers.first?.contentInset.top }
		set { scrollers.forEach { $0.contentInset.top = newValue ?? 0 } }
	}

	var currentIndex: Int = 0 {
		didSet {
			currentIndex = max(0, min(pages.count - 1, currentIndex))
			setViewControllers([pages[currentIndex]], direction: currentIndex > oldValue ? .forward : .reverse, animated: true, completion: nil)
		}
	}

	var currentScroller: UIScrollView { pages[currentIndex].view as! UIScrollView }


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


	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		currentIndex = pages.firstIndex(of: viewControllers!.first!)!
	}
}
