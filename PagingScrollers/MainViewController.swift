//
//  MainViewController.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 13/02/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit


class LeftViewController: UITableViewController {

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
print("Left.cellForRowAt", indexPath)
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
}



class RightViewController: UITableViewController {
}



class MainViewController: UIViewController, UIScrollViewDelegate {

	@IBOutlet private var header: UIView!
	@IBOutlet private var pagerContainer: UIView!

	private var tabController: ProfileTabController!
	private let floatingSize: CGFloat = 54

	private var scroller: UIScrollView { view as! UIScrollView }


	override func viewDidLoad() {
		super.viewDidLoad()
		scroller.delegate = self
		tabController.scrollerTopInsets = header.frame.height
	}


	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		scroller.contentSize = CGSize(width: view.frame.width, height: 1500)
	}


	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		tabController = segue.destination as? ProfileTabController
	}


	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let left = tabController.leftPage.tableView!
		let right = tabController.rightPage.tableView!
		left.contentOffset.y = scrollView.contentOffset.y - left.contentInset.top
		right.contentOffset.y = scrollView.contentOffset.y - right.contentInset.top
	}


	@IBAction private func tabAction(_ sender: UIButton) {
		tabController.currentIndex = sender.tag
	}
}
