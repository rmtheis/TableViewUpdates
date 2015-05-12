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

class RMTSectionInfo: NSObject {

    var open: Bool = false
    var play: RMTPlay!
    var headerView: RMTSectionHeaderView!

    var rowHeights = NSMutableArray()

    func countOfRowHeights() -> Int {
        return self.rowHeights.count
    }

    func objectInRowHeightsAtIndex(idx: Int) -> AnyObject {
        return rowHeights[idx]
    }

    func insertObject(anObject: AnyObject, inRowHeightsAtIndex idx: Int) {
        self.rowHeights.insertObject(anObject, atIndex: idx)
    }

    func insertRowHeights(rowHeightArray: NSArray, atIndexes indexes: NSIndexSet) {
        self.rowHeights.insertObjects(rowHeightArray as [AnyObject], atIndexes: indexes)
    }

    func removeObjectFromRowHeightsAtIndex(idx: Int) {
        self.rowHeights.removeObjectAtIndex(idx)
    }

    func removeRowHeightsAtIndexes(indexes: NSIndexSet) {
        self.rowHeights.removeObjectsAtIndexes(indexes)
    }

    func replaceObjectInRowHeightsAtIndex(idx: Int, withObject anObject: AnyObject) {
        self.rowHeights[idx] = anObject
    }

    func replaceRowHeightsAtIndexes(indexes: NSIndexSet, withRowHeight rowHeightArray: NSArray) {
        self.rowHeights.replaceObjectsAtIndexes(indexes, withObjects: rowHeightArray as [AnyObject])
    }
    
}
