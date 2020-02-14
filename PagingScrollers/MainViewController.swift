//
//  MainViewController.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 13/02/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit


class MainViewController: UIViewController, UIScrollViewDelegate {

	@IBOutlet private var header: UIView!
	@IBOutlet private var headerTop: NSLayoutConstraint!
	@IBOutlet private var pagerContainer: UIView!

	private var profilePager: ProfilePagerViewController!
	private let floatingSize: CGFloat = 54


	override func viewDidLoad() {
		super.viewDidLoad()
		profilePager.scrollers.forEach {
			$0.delegate = self
		}
		profilePager.scrollerTopInsets = header.frame.height
	}


	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		profilePager = segue.destination as? ProfilePagerViewController
	}


	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard profilePager.currentScroller == scrollView else {
			return
		}
		let minHeaderOffset = floatingSize - header.frame.height
		headerTop.constant = max(minHeaderOffset, -(scrollView.contentOffset.y + header.frame.height))
		profilePager.scrollerTopInsets = header.frame.height + min(0, headerTop.constant)
		if headerTop.constant > minHeaderOffset {
			profilePager.scrollers.filter({ $0 != scrollView }).forEach {
				$0.contentOffset = scrollView.contentOffset
			}
		}
	}



	@IBAction private func tabAction(_ sender: UIButton) {
		profilePager.currentIndex = sender.tag
	}

}



class ProfilePagerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	fileprivate var scrollers: [UIScrollView] {
		pages.map({ $0.view as! UIScrollView })
	}


	fileprivate var scrollerTopInsets: CGFloat? {
		get { scrollers.first?.contentInset.top }
		set { scrollers.forEach { $0.contentInset.top = newValue ?? 0 } }
	}


	private lazy var pages: [UIViewController] = {
		[
			storyboard!.instantiateViewController(withIdentifier: "Left"),
			storyboard!.instantiateViewController(withIdentifier: "Right")
		]
	}()


	fileprivate var currentIndex: Int = 0 {
		didSet {
			currentIndex = max(0, min(pages.count - 1, currentIndex))
			setViewControllers([pages[currentIndex]], direction: currentIndex > oldValue ? .forward : .reverse, animated: true, completion: nil)
		}
	}


	fileprivate var currentScroller: UIScrollView { pages[currentIndex].view as! UIScrollView }


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
