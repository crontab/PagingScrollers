//
//  PagingScroller.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 03/07/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit


@objc protocol PagingScrollerDelegate: class {
	func pagingScroller(_ pagingScroller: PagingScroller, didSelectIndex index: Int) // for interactive swipes only
}


@IBDesignable
class PagingScroller: UIScrollView, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	@IBOutlet
	public weak var pagingScrollerDelegate: PagingScrollerDelegate?


	// MARK: - public interface

	var pages: [UIViewController] = [] {
		didSet {
			contentSize = .zero
			contentOffset = .zero
			scrollers = pages.map({ $0.view as? UIScrollView })
			currentIndex = 0
		}
	}


	var currentIndex: Int {
		get {
			_currentIndex
		}
		set {
			pager.setViewControllers([pages[newValue]], direction: newValue > _currentIndex ? .forward : .reverse, animated: true, completion: nil)
			willPage(to: newValue)
			_currentIndex = newValue
			didPage()
		}
	}


	// MARK: - internal

	private var pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	private var scrollers: [UIScrollView?] = []
	private var _currentIndex: Int = 0


	override func awakeFromNib() {
		super.awakeFromNib()

		showsVerticalScrollIndicator = false
		alwaysBounceVertical = true

		pager.view.frame = bounds
		pager.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(pager.view)

		pager.delegate = self
		pager.dataSource = self
	}


	private func willPage(to index: Int) {
		if !scrollers.isEmpty, let scroller = scrollers[index] {
			scroller.contentInset = contentInset
		}
	}


	private func didPage() {
		if !scrollers.isEmpty, let scroller = scrollers[_currentIndex] {
			contentSize = scroller.contentSize
			contentOffset = scroller.contentOffset
		}
	}


	private func didScroll() {
		if !scrollers.isEmpty, let scroller = scrollers[_currentIndex] {
			scroller.contentOffset = contentOffset
		}
	}


	// MARK: - protected

	override func layoutSubviews() {
		super.layoutSubviews()
		if contentSize.height == 0 {
			didPage()
		}
		// Pass the scroll position down to nested scroll views, to create an illustion that the user is moving the nested ones
		didScroll()
		// At the same time, keep the pager itself "floating", i.e. fixed
		pager.view.frame.origin.y = contentOffset.y
	}


	override var contentInset: UIEdgeInsets {
		didSet {
			for scroller in scrollers {
				scroller?.contentInset = contentInset
			}
		}
	}


	// MARK: - page view controller delegate/data source

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


	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		let newIndex = pages.firstIndex(of: pager.viewControllers!.first!)!
		willPage(to: newIndex)
	}


	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			_currentIndex = pages.firstIndex(of: pager.viewControllers!.first!)!
			pagingScrollerDelegate?.pagingScroller(self, didSelectIndex: _currentIndex)
			didPage()
		}
	}
}
