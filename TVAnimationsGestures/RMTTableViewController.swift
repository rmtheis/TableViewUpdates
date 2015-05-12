/*
* Copyright 2015 Robert Theis
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may not
* use this file except in compliance with the License. You may obtain a copy of
* the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations under
* the License.
*/

import MessageUI // for MFMailComposeViewControllerDelegate

class EmailMenuItem: UIMenuItem {
    var indexPath: NSIndexPath!
}

// MARK: -

class RMTTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, SectionHeaderViewDelegate {

    let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
    var plays: NSArray!
    var sectionInfoArray: NSMutableArray!
    var pinchedIndexPath: NSIndexPath!
    var opensectionindex: Int!
    var initialPinchHeight: CGFloat!

    var sectionHeaderView: RMTSectionHeaderView!

    // Use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously
    var uniformRowHeight: Int!

    let DefaultRowHeight = 88
    let HeaderHeight = 48

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a pinch gesture recognizer to the table view.
        var pinchRecognizer = UIPinchGestureRecognizer(target: self, action:"handlePinch:")
        self.tableView.addGestureRecognizer(pinchRecognizer)

        // Set up default values.
        self.tableView.sectionHeaderHeight = CGFloat(HeaderHeight)

        /*
        The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
        */
        self.uniformRowHeight = DefaultRowHeight
        self.opensectionindex = NSNotFound

        let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)

        self.tableView.registerNib(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        /*
        Check whether the section info array has been created, and if so whether the section count still matches the current section count. In general, you need to keep the section info synchronized with the rows and section. If you support editing in the table view, you need to appropriately update the section info during editing operations.
        */
        if self.sectionInfoArray == nil || self.sectionInfoArray.count != self.numberOfSectionsInTableView(self.tableView) {

            // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
            var infoArray = NSMutableArray()

            for play in self.plays {
                var sectionInfo = RMTSectionInfo()
                sectionInfo.play = play as! RMTPlay
                sectionInfo.open = false

                var defaultRowHeight = DefaultRowHeight
                var countOfQuotations = sectionInfo.play.quotations.count
                for (var i = 0; i < countOfQuotations; i++) {
                    sectionInfo.insertObject(defaultRowHeight, inRowHeightsAtIndex: i)
                }

                infoArray.addObject(sectionInfo)
            }

            self.sectionInfoArray = infoArray
        }
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return self.plays.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionInfo = self.sectionInfoArray[section] as! RMTSectionInfo
        var numStoriesInSection = sectionInfo.play.quotations.count

        return sectionInfo.open ? numStoriesInSection : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let QuoteCellIdentifier = "QuoteCellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(QuoteCellIdentifier) as! RMTQuoteCell

        if MFMailComposeViewController.canSendMail() {

            if cell.longPressRecognizer == nil {
                var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
                cell.longPressRecognizer = longPressRecognizer
            }
        }
        else {
            cell.longPressRecognizer = nil
        }

        let play: RMTPlay = (self.sectionInfoArray[indexPath.section] as! RMTSectionInfo).play
        cell.quotation = play.quotations[indexPath.row] as! RMTQuotation

        return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var sectionHeaderView: RMTSectionHeaderView = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(SectionHeaderViewIdentifier) as! RMTSectionHeaderView

        var sectionInfo: RMTSectionInfo = self.sectionInfoArray[section] as! RMTSectionInfo
        sectionInfo.headerView = sectionHeaderView

        sectionHeaderView.titleLabel.text = sectionInfo.play.name
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self

        return sectionHeaderView
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let sectionInfo: RMTSectionInfo = self.sectionInfoArray[indexPath.section] as! RMTSectionInfo
        return CGFloat(sectionInfo.objectInRowHeightsAtIndex(indexPath.row) as! NSNumber)
        // Alternatively, return rowHeight.
    }

    // MARK: - SectionHeaderViewDelegate

    func sectionHeaderView(sectionHeaderView: RMTSectionHeaderView, sectionOpened: Int) {

        var sectionInfo: RMTSectionInfo = self.sectionInfoArray[sectionOpened] as! RMTSectionInfo

        sectionInfo.open = true

        /*
        Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
        */
        var countOfRowsToInsert = sectionInfo.play.quotations.count
        var indexPathsToInsert = NSMutableArray()
        for (var i = 0; i < countOfRowsToInsert; i++) {
            indexPathsToInsert.addObject(NSIndexPath(forRow: i, inSection: sectionOpened))
        }

        /*
        Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
        */
        var indexPathsToDelete = NSMutableArray()

        var previousOpenSectionIndex = self.opensectionindex
        if previousOpenSectionIndex != NSNotFound {

            var previousOpenSection: RMTSectionInfo = self.sectionInfoArray[previousOpenSectionIndex] as! RMTSectionInfo
            previousOpenSection.open = false
            previousOpenSection.headerView.toggleOpenWithUserAction(false)
            let countOfRowsToDelete = previousOpenSection.play.quotations.count
            for (var i = 0; i < countOfRowsToDelete; i++) {
                indexPathsToDelete.addObject(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
        }

        // Style the animation so that there's a smooth flow in either direction
        var insertAnimation: UITableViewRowAnimation
        var deleteAnimation: UITableViewRowAnimation
        if previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex {
            insertAnimation = UITableViewRowAnimation.Top
            deleteAnimation = UITableViewRowAnimation.Bottom
        }
        else {
            insertAnimation = UITableViewRowAnimation.Bottom
            deleteAnimation = UITableViewRowAnimation.Top
        }

        // Apply the updates
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete as [AnyObject], withRowAnimation: deleteAnimation)
        self.tableView.insertRowsAtIndexPaths(indexPathsToInsert as [AnyObject], withRowAnimation: insertAnimation)
        self.tableView.endUpdates()

        self.opensectionindex = sectionOpened
    }

    func sectionHeaderView(sectionHeaderView: RMTSectionHeaderView, sectionClosed: Int) {

        /*
        Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
        */
        var sectionInfo = self.sectionInfoArray[sectionClosed] as! RMTSectionInfo

        sectionInfo.open = false
        let countOfRowsToDelete = self.tableView.numberOfRowsInSection(sectionClosed)

        if countOfRowsToDelete > 0 {
            var indexPathsToDelete = NSMutableArray()
            for (var i = 0; i < countOfRowsToDelete; i++) {
                indexPathsToDelete.addObject(NSIndexPath(forRow: i, inSection: sectionClosed))
            }
            self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete as [AnyObject], withRowAnimation: UITableViewRowAnimation.Top)
        }
        self.opensectionindex = NSNotFound
    }

    // MARK: - Handling pinches

    func handlePinch(pinchRecognizer: UIPinchGestureRecognizer) {

        /*
        There are different actions to take for the different states of the gesture recognizer.
        * In the Began state, use the pinch location to find the index path of the row with which the pinch is associated, and keep a reference to that in pinchedIndexPath. Then get the current height of that row, and store as the initial pinch height. Finally, update the scale for the pinched row.
        * In the Changed state, update the scale for the pinched row (identified by pinchedIndexPath).
        * In the Ended or Canceled state, set the pinchedIndexPath property to nil.
        */

        if pinchRecognizer.state == .Began {

            let pinchLocation = pinchRecognizer.locationInView(self.tableView)

            if let newPinchedIndexPath = self.tableView.indexPathForRowAtPoint(pinchLocation) {
                self.pinchedIndexPath = newPinchedIndexPath

                let sectionInfo = self.sectionInfoArray[newPinchedIndexPath.section] as? RMTSectionInfo
                self.initialPinchHeight = sectionInfo!.objectInRowHeightsAtIndex(newPinchedIndexPath.row) as! CGFloat
                // Alternatively, set initialPinchHeight = uniformRowHeight.

                self.updateForPinchScale(pinchRecognizer.scale, indexPath: newPinchedIndexPath)
            }
        }else {
            if pinchRecognizer.state == .Changed {
                self.updateForPinchScale(pinchRecognizer.scale, indexPath: self.pinchedIndexPath)
            }
            else if pinchRecognizer.state == .Cancelled || pinchRecognizer.state == .Ended {
                self.pinchedIndexPath = nil
            }
        }
    }

    func updateForPinchScale(scale: CGFloat, indexPath: NSIndexPath?) {

        if indexPath != nil && indexPath!.section != NSNotFound && indexPath!.row != NSNotFound {

            let newHeight: CGFloat = round(max(initialPinchHeight * scale, CGFloat(DefaultRowHeight)))

            let sectionInfo = self.sectionInfoArray[indexPath!.section] as! RMTSectionInfo
            sectionInfo.replaceObjectInRowHeightsAtIndex(indexPath!.row, withObject: (newHeight))
            // Alternatively, set uniformRowHeight = newHeight.

            /*
            Switch off animations during the row height resize, otherwise there is a lag before the user's action is seen.
            */
            let animationsEnabled = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(animationsEnabled)
        }
    }

    // MARK: - Handling long presses

    func handleLongPress(longPressRecognizer: UILongPressGestureRecognizer) {

        /*
        For the long press, the only state of interest is Began.
        When the long press is detected, find the index path of the row (if there is one) at press location.
        If there is a row at the location, create a suitable menu controller and display it.
        */
        if longPressRecognizer.state == .Began {

            if let pressedIndexPath = self.tableView.indexPathForRowAtPoint(longPressRecognizer.locationInView(self.tableView)) {

                if pressedIndexPath.row != NSNotFound && pressedIndexPath.section != NSNotFound {

                    self.becomeFirstResponder()
                    let title = NSBundle.mainBundle().localizedStringForKey("Email", value: "Email menu title", table: nil)
                    let menuItem: EmailMenuItem = EmailMenuItem(title: title, action: "emailMenuButtonPressed:")
                    menuItem.indexPath = pressedIndexPath

                    let menuController = UIMenuController.sharedMenuController()
                    menuController.menuItems = [menuItem]

                    var cellRect = self.tableView.rectForRowAtIndexPath(pressedIndexPath)
                    // Lower the target rect a bit (so not to show too far above the cell's bounds)
                    cellRect.origin.y += 40.0
                    menuController.setTargetRect(cellRect, inView: self.tableView)
                    menuController.setMenuVisible(true, animated: true)
                }
            }
        }
    }

    func emailMenuButtonPressed(menuController: UIMenuController) {

        if let menuItem: EmailMenuItem = UIMenuController.sharedMenuController().menuItems![0] as? EmailMenuItem {
            resignFirstResponder()
            sendEmailForEntryAtIndexPath(menuItem.indexPath)
        }
    }

    func sendEmailForEntryAtIndexPath(indexPath: NSIndexPath) {

        let play = plays[indexPath.section] as! RMTPlay
        let quotation = play.quotations[indexPath.row] as! RMTQuotation
        
        // In production, send the appropriate message.
        println("Send email using quotation:\n\(quotation.quotation)")
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        dismissViewControllerAnimated(true, completion: nil)
        if result.value == MFMailComposeResultFailed.value {
            // In production, display an appropriate message to the user.
            println("Mail send failed with error: \(error)")
        }
    }
    
}
