//
//  SegmentedControl.swift
//
//  Created by Hovik Melikyan on 13/11/2019.
//  Copyright © 2019 Hovik Melikyan. All rights reserved.
//

import UIKit


@objc public protocol SegmentedControlDelegate: class {
	func segmentedControl(_ segmentedControl: SegmentedControl, didSelectIndex index: Int)
}


@IBDesignable
open class SegmentedControl: UIView {

	@IBOutlet
	public weak var delegate: SegmentedControlDelegate?


	@IBInspectable
	open var segmentTitles: String {
		get { segments.map({ $0.title ?? "" }).joined(separator: ",") }
		set {
			let newValue = newValue.split(separator: ",")
			let segments = self.segments
			segments.forEach { $0.removeFromSuperview() }
			for i in 0..<newValue.count {
				let segment = Segment(frame: CGRect.zero)
				segment.title = String(newValue[i])
				segment.tag = i
				segment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
				addSubview(segment)
			}
			setSelectedSegmentIndex(min(newValue.count - 1, selectedSegmentIndex), animated: false)
		}
	}


	@IBInspectable
	open private(set) var selectedSegmentIndex: Int = 0


	open func setSelectedSegmentIndex(_ index: Int, animated: Bool) {
		selectedSegmentIndex = index
		let segments = self.segments
		for i in 0..<segments.count {
			segments[i].selected = i == selectedSegmentIndex
		}
		if animated {
			UIView.animate(withDuration: 0.15) {
				self.updateSelectorPosition()
			}
		}
		else {
			updateSelectorPosition()
		}
	}


	open var segments: [Segment] { subviews.compactMap { $0 as? Segment } }


	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupSelector()
		setupSwipeGestures()
	}


	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setupSelector()
		setupSwipeGestures()
	}


	open override func layoutSubviews() {
		super.layoutSubviews()
		let segments = self.segments
		let w = frame.width / CGFloat(segments.count)
		for i in 0..<segments.count {
			segments[i].frame = CGRect(x: w * CGFloat(i), y: 0, width: w, height: frame.height)
			let titleSize = segments[i].labelRect.size
			if titleSize.width > maxTitleSize.width {
				maxTitleSize = titleSize
			}
		}
		updateSelectorPosition()
	}


	#if TARGET_INTERFACE_BUILDER
	open override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupSelector()
		if segments.count == 0 {
			segmentTitles = "Segment 1,Segment 2"
			segments[1].badgeCount = 5
		}
	}
	#endif


	private var selector: UIView = UIView(frame: CGRect.zero)
	private var maxTitleSize: CGSize = .zero


	private func setupSelector() {
		if selector.superview == nil {
			selector.backgroundColor = Segment.selectorBgColor
			selector.isHidden = true
			insertSubview(selector, at: 0)
		}
	}


	private func setupSwipeGestures() {
		var swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
		swipe.direction = .left
		addGestureRecognizer(swipe)
		swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
		swipe.direction = .right
		addGestureRecognizer(swipe)
	}


	private func updateSelectorPosition() {
		let segments = self.segments
		let w = frame.width / CGFloat(segments.count)
		selector.frame.size = CGSize(width: maxTitleSize.width + 44, height: maxTitleSize.height + 10)
		selector.center = CGPoint(x: (CGFloat(selectedSegmentIndex) + 0.5) * w, y: frame.height / 2)
		selector.layer.cornerRadius = selector.frame.height / 2
		let showSelector = segments.indices.contains(selectedSegmentIndex)
		selector.isHidden = !showSelector
	}


	@objc private func tapAction(_ sender: UITapGestureRecognizer) {
		setSelectedSegmentIndex(sender.view!.tag, animated: true)
		delegate?.segmentedControl(self, didSelectIndex: selectedSegmentIndex)
	}


	@objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
		let segments = self.segments
		let point = sender.location(in: self)
		if let currentIndex = segments.firstIndex(where: { $0.frame.contains(point) }), currentIndex == selectedSegmentIndex {
			let newIndex = currentIndex + (sender.direction == .left ? -1 : 1)
			if segments.indices.contains(newIndex) {
				setSelectedSegmentIndex(newIndex, animated: true)
				delegate?.segmentedControl(self, didSelectIndex: selectedSegmentIndex)
			}
		}
	}


	// MARK: - Segment component

	public class Segment: UIView {

		public var title: String? {
			didSet {
				label.text = title?.uppercased()
			}
		}


		public var inactiveBadgeColor: UIColor = .gray {
			didSet { updateColors() }
		}


		public var badgeCount: Int = 0 {
			didSet {
				badge.setText(badgeCount >= 100 ? "99+" : badgeCount != 0 ? String(badgeCount) : nil, withPopupAnimation: true)
			}
		}


		private static var textFont: UIFont = { .systemFont(ofSize: 12, weight: .bold) }()
		private static var badgeFont: UIFont = { .systemFont(ofSize: 10, weight: .bold) }()
		private static var inactiveTextColor: UIColor = { .init(white: 0, alpha: 0.5) }()
		private static var activeTextColor: UIColor = { .black }()
		private static var activeBadgeBgColor: UIColor = { .black }()
		fileprivate static var selectorBgColor: UIColor = { .init(white: 234 / 255, alpha: 1) }()

		private var label: UILabel
		private var badge: Badge


		override init(frame: CGRect) {
			self.label = UILabel(frame: CGRect.zero)
			self.badge = Badge(frame: .zero)

			super.init(frame: frame)

			label.font = Self.textFont
			label.textColor = Self.inactiveTextColor
			addSubview(label)

			badge.font = Self.badgeFont
			badge.textColor = .white
			badge.backgroundColor = inactiveBadgeColor
			badge.clipsToBounds = true
			badge.textAlignment = .center
			badge.isHidden = true
			addSubview(badge)
		}


		required init?(coder: NSCoder) { preconditionFailure() }


		public override func layoutSubviews() {
			super.layoutSubviews()
			if let superview = label.superview {
				let badgeWillHide = badge.text == nil
				let indent = badgeWillHide ? 0 : badge.bounds.width + 5
				let badgeWidth = badgeWillHide ? 0 : badge.bounds.width
				label.sizeToFit()
				label.center = CGPoint(x: (superview.bounds.width + indent) / 2, y: superview.bounds.height / 2)
				badge.center = CGPoint(x: label.frame.minX - 5 - badgeWidth / 2, y: label.center.y)
			}
		}


		fileprivate var selected: Bool = false {
			didSet { updateColors() }
		}


		private func updateColors() {
			label.textColor = selected ? Self.activeTextColor : Self.inactiveTextColor
			badge.backgroundColor = selected ? Self.activeBadgeBgColor : inactiveBadgeColor
		}


		fileprivate var labelRect: CGRect {
			layoutSubviews()
			return label.frame
		}
	}


	// MARK: - Badge component

	private class Badge: UILabel {

		func setText(_ text: String?, withPopupAnimation animated: Bool) {
			let hide = text == nil
			let hiddenChanged = hide != self.isHidden
			if hiddenChanged && animated {
				let hideTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
				self.transform = hide ? CGAffineTransform.identity : hideTransform
				self.isHidden = false
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: hide ? 1 : 0.5, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
					self.text = text
					self.superview?.layoutIfNeeded()
					self.transform = hide ? hideTransform : CGAffineTransform.identity
				}) { (finished) in
					self.isHidden = hide
				}
			}
			else {
				self.isHidden = hide
				self.text = text
			}
		}

		override func layoutSubviews() {
			super.layoutSubviews()
			let side = font.pointSize * 16 / 10
			let textWidth = intrinsicContentSize.width
			bounds.size = .init(width: max(side, textWidth + 6), height: side)
			layer.cornerRadius = side / 2
		}
	}
}
