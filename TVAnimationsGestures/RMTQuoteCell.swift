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

class RMTQuoteCell: UITableViewCell {

    @IBOutlet var characterLabel: UILabel!
    @IBOutlet var actAndSceneLabel: UILabel!
    @IBOutlet var quotationTextView: RMTHighlightingTextView!

    var quotation: RMTQuotation! {
        didSet {
            self.characterLabel.text = quotation.character
            self.actAndSceneLabel.text = "Act \(quotation.act), Scene \(quotation.scene)"
            self.quotationTextView.text = quotation.quotation
        }
    }

    var longPressRecognizer: UILongPressGestureRecognizer? {
        willSet {
            if longPressRecognizer != nil {
                removeGestureRecognizer(self.longPressRecognizer!)
            }
        }
        didSet {
            if longPressRecognizer != nil {
                addGestureRecognizer(longPressRecognizer!)
            }
        }
    }
    
}
