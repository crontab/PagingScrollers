//
//  MainViewController.swift
//  PagingScrollers
//
//  Created by Hovik Melikyan on 13/02/2020.
//  Copyright © 2020 Eleven Life. All rights reserved.
//

import UIKit


class TestTableView: UITableView {
}


class TestTableViewController: UITableViewController {
}


class LeftViewController: TestTableViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 30
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LeftTestCell", for: indexPath)
		cell.textLabel?.text = "Left \(indexPath.row)"
		return cell
	}
}


class RightViewController: TestTableViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 7
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RightTestCell", for: indexPath)
		cell.textLabel?.text = "Right \(indexPath.row)"
		return cell
	}
}


class MainViewController: UIViewController, PagingScrollerDelegate, SegmentedControlDelegate, UIScrollViewDelegate {

	@IBOutlet private var pagingScroller: PagingScroller!
	@IBOutlet private var segmentedControl: SegmentedControl!


	override func viewDidLoad() {
		super.viewDidLoad()

		pagingScroller.pages = [
			storyboard!.instantiateViewController(withIdentifier: "Left"),
			storyboard!.instantiateViewController(withIdentifier: "Right"),
		]

		// pagingScroller.contentInset.top = 100
	}


	func segmentedControl(_ segmentedControl: SegmentedControl, didSelectIndex index: Int) {
		pagingScroller.currentIndex = index
	}

	func pagingScroller(_ pagingScroller: PagingScroller, didSelectIndex index: Int) {
		segmentedControl.setSelectedSegmentIndex(index, animated: true)
	}
}
