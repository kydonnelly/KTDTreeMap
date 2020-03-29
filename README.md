# KTDTreeMap

KTDTreeMap is an easy to use library for showing tree maps in an iOS UICollectionView. Tree Maps are a way to visualize related information in a way that maximizes space usage. Traditional pie charts or binary trees have lots of whitespace; tree maps fill their entire area.

## Getting Started

Clone the repo and run 'pod install' in the directory. Open the .xcworkspace and run the demo app.

## Prerequisites

Cocoapods ≥ 1.3.0
Xcode ≥ 9.3.1
iOS ≥ 9.0

## Installing

Add the following to your Podfile:

```ruby
platform :ios, '9.0'
source 'https://github.com/kydonnelly/specs.git'
use_modular_headers!
pod 'KTDTreeMap', :testspecs => ['Tests']
```

## Use Cases

Similar to a pie chart, you can use this to display weighted parts of a whole. For example you might display file usage or categorized monthly expenses.

Some tree maps allow zooming to view detailed breakdowns within a part at a more granular level. Currently this library only supports a single level (no zooming).

## Implementation

Add a UICollectionView to your storyboard. Change its class to TreeMapCollectionView. Connect the dataSource and delegate IBOutlets as usual. The delegate must implement TreeMapCollectionViewDataSource in addition to UICollectionViewDataSource.

![Interface Builder Demo](https://cooperative4thecommunity.com/wp-content/uploads/2020/03/TreeMapInterfaceBuilder.png)

![Implementation Demo](https://cooperative4thecommunity.com/wp-content/uploads/2020/03/TreeMapDefinition.png)

![Square Tree Map Example](https://cooperative4thecommunity.com/wp-content/uploads/2020/03/TreeMapSquare.png)

## Running unit tests

After installing the pod and opening the xcworkspace, go to Manage Schemes and select KTDTreeMap-Unit-Tests. Close the Manage Schemes screen, select the unit test target, and Cmd+U to run test cases.

## License

MPL v2, see file.

## Acknowledgements

Inspiration from openbudgetoakland.org.

Encouraged by Emily and Stephanie.

Square Tree Map algorithm based on https://www.win.tue.nl/~vanwijk/stm.pdf
