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


class MainViewController: UIViewController, UIScrollViewDelegate {

	@IBOutlet var pagingScroller: PagingScroller!


	override func viewDidLoad() {
		super.viewDidLoad()

		pagingScroller.pages = [
			storyboard!.instantiateViewController(withIdentifier: "Left"),
			storyboard!.instantiateViewController(withIdentifier: "Right"),
		]
	}
}
