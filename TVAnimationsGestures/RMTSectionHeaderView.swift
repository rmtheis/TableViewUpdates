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

import UIKit

protocol SectionHeaderViewDelegate: class, NSObjectProtocol {
    func sectionHeaderView(sectionHeaderView: RMTSectionHeaderView, sectionOpened: Int)
    func sectionHeaderView(sectionHeaderView: RMTSectionHeaderView, sectionClosed: Int)
}

class RMTSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var disclosureButton: UIButton!

    var delegate: SectionHeaderViewDelegate!

    var section: Int = 0

    override func awakeFromNib() {

        // Set the selected image for the disclosure button
        disclosureButton.setImage(UIImage(named: "caret-open"), forState: UIControlState.Selected)

        // Set up the tap gesture recognizer
        var tapGesture = UITapGestureRecognizer(target: self, action: "toggleOpen:")

        addGestureRecognizer(tapGesture)
    }

    @IBAction func toggleOpen(sender: UITapGestureRecognizer) {
        toggleOpenWithUserAction(true)
    }

    func toggleOpenWithUserAction(userAction: Bool) {

        // Toggle the disclosure button state
        self.disclosureButton.selected = !self.disclosureButton.selected

        // If this was a user action, send the delegate the appropriate message
        if userAction {
            if self.disclosureButton.selected {
                if self.delegate.respondsToSelector("sectionHeaderView:sectionOpened:") {
                    self.delegate.sectionHeaderView(self, sectionOpened: self.section)
                }
            }
            else {
                if self.delegate.respondsToSelector("sectionHeaderView:sectionClosed:") {
                    self.delegate.sectionHeaderView(self, sectionClosed: self.section)
                }
            }
        }
    }
}
