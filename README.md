# CampusNav

[https://github.com/campusnav/CampusNav](https://github.com/campusnav/CampusNav)

![combine_images](https://f.cloud.github.com/assets/510089/1526980/4ed8916a-4bed-11e3-9f98-fb7a540c245d.png)

## Notes

- This is a private group project for school, for academic purpose. 
- Any reuse of the code is not authorized. 
- We do not responsible for anything may caused by using our code. 
- Unless specified, all the codes in this repo is written by ourselves. 

__ALL RIGHTS RESERVED__

Included third party open source codes

1. _FMDB_: An Objective-C wrapper around SQLite by ccgus
2. _ocean_: A free iOS interface customize template from appdesignvault.com


## System Implementation Overview

### Underlying Technical Complexity

- The queries with SQLite database are all done through _FMDB_. 
- _GeoGraph System_ as a whole, is the subsystem responsible for executing database query and data packing. It provide a facade interface for upper layer subsystems (i.e., _GeoGraph Utilities_) to access all the Geographic data. 
- _User Profile_ is the subsystem responsible to store user's favorites and user's search history (not implemented yet). It utilize the _Core Data_ storage provide by iOS SDK to store all the contents generated by the user. One important reason for us to choose _Core Data_ for this task is, everything saved in it are automatically backed up in _iCloud_. 
- We use _Xcode_ as the IDE (No other choice). No code generation tools. All the elements in our design are mapped by hand. Thanks _Xcode_'s auto completion. 

### Implementation Process

- Accomplished: 
    - Browse all the POIs in a building / on a floor
    - Favorite's management
    - Navigation in the same building
- Future Enhancements: 
    - Implement the calculation of path between buildings
    - Use the [IPS technology](http://phys.org/news/2012-07-finland-team-earth-magnetic-field.html) to track user's location accurately indoor and do turn by turn navigation.
    
## Compliance with Software Architecture

### Subsystem Design

- GeoGraph System (`GGSystem`)
    - Besides the facade, _singleton_ and _proxy_ pattern is used. 
    - Upper layer components obtain the GeoGraph System singleton instance by calling `[GGSystem sharedGeoGraphSystem]`. 
    - Three dictionaries (for buildings, floorPlans and points) are used in the system implementation for data caching. 
    - GeoGraph Components
        - The connections between components (i.e., a floorPlan belongs to a building) are weak links represent by id's (i.e., each building has a `bId`). 
        - Component user can directly access the connected components as readonly. Underlying, the component will ask the `GGSystem` singleton to provide the connected component objects, rather than save them directly. 
        - Therefore, all the components are cached and managed by `GGSystem`. Results in lower coupling between components. 

- GeoGraph Utilities (`GGPool`)
    - These are the containers for GeoGraph data. Include couple of utility functions to fetch/filter the data. 
    - All the View Controllers, who deal with a pile of data from `GGSystem`, use these containers to obtain useful information. 

- User Profile (`CNUserProfile`)
    - It is implemented with _singleton_ pattern as well, since _Core Data_'s `managedObjectContext` is singleton at the first place. 
    - It manages the user's favorites (and history in the future). Providing methods for upper layer components to add, remove or modify the user's favorites. 

- Path Calculation (`CNPathCalculator`)
    - `CNPathCalculator` is a template class. To calculate, must be instantiated as `CNSameFloorPathCalculator` or `CNSameBuildingPathCalculator`. Different calculator use different details in each step. 
    - All the calculator start the calculation upon `executeCalculation` call. 
    - Ideally, the calculation should be done asynchronously, and post an `kCNPathCalculationDidFinishNotification` notification with the calculation result. But for now, since the calculation is not too slow to be done synchronously, this mechanism has not been implemented. 

- View Controllers
    - These are all the UI controllers, one for each view. The views are defined in `Storyboard`. 
    - Currently, the floor plan map rendering is in the controller logic. But they should definitely be placed into a separate subsystem and done asynchronously. 

### Architectural Drift and Erosion

#### Drifts
- _GGBuilding_
    - This data structure is added to generalize the data hierarchy. So that one Building can contain more information rather than just a name. 
- History is not implemented yet. 
- The path calculation and map rendering was designed to be done asynchronously. Not implemented due to time limitation. 

#### Erosion
- _GGPool_ and its children class is used instead of _POI Utility_. _POI Utility_ subsystem was designed with too narrowed functionality. 

## Compliance with Detailed Software Design

### Control Flow Implementation

- The navigation and communication between controllers are done in two different way: 
    1. If there is a _segue_ define in `Storyboard`, the new view is a direct _pushed_ to the `UINavigationController`'s stack and present to the user. Data are passed to the new view by overriding the `- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender` method. 
    2. If there is not a _segue_, then the new view is trying to _promote_ itself to the front upon receiving a _notification_ (i.e., `kCNNavConfigNotification` is received for navigation _source_ or _destination_ changes). Data are passed together with the _notification_. 
- The data for all the _ViewController_ come from _GeoGraph Utilities_, _User Profile_ or _Path Calculation_. The lower layer _GeoGraph System_ may be include to accessing the data structures, but no direct call to `GGSystem`. 

### Boundary Control Implementation

- Initialization
    - `CNUICustomize`'s class methods (static methods) will be called in `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` to customize the UI components . 
    - All the singletons are initiated lazily. 
    - _View Controllers_ are created by the iOS System/SDK implicitly. 


