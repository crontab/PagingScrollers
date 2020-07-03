//
//  PagingScroller.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 03/07/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit


class PagingScroller: UIScrollView, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	// MARK: - setup

	private var pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	private var scrollers: [UIScrollView?] = []

	override func awakeFromNib() {
		super.awakeFromNib()

		pager.view.frame = bounds
		pager.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(pager.view)

		pager.delegate = self
		pager.dataSource = self

		showsVerticalScrollIndicator = true
	}


	private func updateLayout() {
		var newSize = bounds.size
		for scroller in scrollers.compactMap({ $0 }) {
			newSize.height = max(newSize.height, scroller.contentSize.height)
			scroller.contentInset = contentInset
		}
		contentSize = newSize
	}


	// MARK: - public interface

	var pages: [UIViewController] = [] {
		didSet {
			scrollers = pages.map({ $0.view as? UIScrollView })
			pager.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
			updateLayout()
		}
	}


	var currentIndex: Int = 0 {
		didSet {
			// profileTabControllerDelegate?.profileTabControllerWillChangeIndex(currentPage)
			pager.setViewControllers([pages[currentIndex]], direction: currentIndex > oldValue ? .forward : .reverse, animated: true, completion: nil)
			updateLayout()
		}
	}


	// MARK: - protected

	override func layoutSubviews() {
		super.layoutSubviews()
		pager.view.frame.origin.y = contentOffset.y
	}


	override var contentOffset: CGPoint {
		didSet {
			if currentIndex < scrollers.count, let scroller = scrollers[currentIndex] {
				scroller.contentOffset = contentOffset
			}
		}
	}


	// MARK: - page view controller delegate/data source

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index > 0 else {
			return nil
		}
		// profileTabControllerDelegate?.profileTabControllerWillChangeIndex(Page(rawValue:index - 1)!)
		return pages[index - 1]
	}


	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
			return nil
		}
		// profileTabControllerDelegate?.profileTabControllerWillChangeIndex(Page(rawValue:index - 1)!)
		return pages[index + 1]
	}


	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		currentIndex = pages.firstIndex(of: pager.viewControllers!.first!)!
	}
}
