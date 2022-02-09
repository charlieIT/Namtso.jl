

### Summary

### Added

#### Grid dimensions

 - Added support for percentual and text based `width` and `height`, as per [Grid.width](https://echarts.apache.org/en/option.html#grid.width) and [Grid.height](https://echarts.apache.org/en/option.html#grid.height)
 - Added initial support for container size reactivity, as per [Reactivity of the container size](https://echarts.apache.org/handbook/en/concepts/chart-size/#reactive-of-the-container-size)
 - Added `GridDimension = Union{Int64, String}`
 - Added constants `DEFAULT_WIDTH` and `DEFAULT_HEIGHT`
 
#### Rendering
 
 - Added support for `canvas` and `svg` rendering
 - Added abstract type `Renderer`
 - Added types `Canvas` and `SVG`
 - Added JSON.json implementation over a `Renderer` type to produce the appropriate renderer directive
 
#### Axis

 - Added abstract type `Axis`, subtypes `xAxis` and `yAxis` for improving operations over axis in `series!`, under `ECharts/Base.jl`
 - Added `Base.getindex` implementation of an `Axis` over a `Series` object
 - Added `Base.string` implementation over `xAxis` and `yAxis`
  
#### Options
 
 - Added file `ECharts/Options.jl`
 - Added `abstract type Options`
 - Added Options subtypes `PlotOptions`, `SeriesOptions`, `DataOptions`
 
#### EChart

 - Added property `resize`, a boolean value, to indicate whether `container size reactivity` should be added to the chart's js script
 - Added property `renderer` to signal desired rendering method when displaying the chart
 - Added keyword constructor
 
#### Series
 
 - Added methods `set_axis!` and `append_axis!` to generalize `axis` setup, type and length validations
 
#### Tools

 - Added submodule `Tools`
 - Added auxiliary methods `prepareboxplot` as a Julia implementation of [echarts tools.prepareBoxPlotData](https://github.com/apache/incubator-echarts/blob/master/extension-src/dataTool/prepareBoxplotData.ts) 
 - Added method documentation via docstrings

### Fixed

#### Series

 - Added improved support for alternative series data definitions, as per `echarts.js` examples
 - Attempted to fix some issues when defining `series` and `charts`, without providing data arrays for the axis, which made it difficult to easily define series from alternative datasets
 
#### BoxPlot

 - Fixed impossibility of invoking internal `echarts.dataTool` to transform plot data into the appropriate boxplot and outliers format 
 - Fixed need for custom, project specific, statistical logic for devising quantiles, minimum, maximum, median and outlier values of a dataset in order to build a boxplot
 
#### Rendering and Grid Dimensions

 - Fixed impossibility of defining a grid's dimension as a percentual value `e.g. width=50%, height=50%` or as an acceptable text value `e.g auto`
 - Fixed impossibility of requiring charts to be rendered as graphic vector - SVG

### Changed

#### Base definitions

 - Sorted `BASE_OPTIONS` alphabetically
 - Added `dataset` to `BASE_OPTIONS` to support dataset based charts and series
 - Moved `EChart` definition and constructors to separate file
 - Moved `public script` url from `ECharts/Show.jl` to a separate constant `PUBLIC_SCRIPT`
 
#### EChart

 - Moved EChart definition and constructors to separate file, under `ECharts/EChart.jl`
 - Changed `width` and `height` property types to type `GridDimension = Union{Int64, String}`
 - Changed `width` and `height` defaults to `DEFAULT_WIDTH` and `DEFAULT_HEIGHT` respectively
 - Added default `kwarg` based constructor with default values
 
#### Series

 - Update `series!` to init default `axis` values, if none are yet defined
 - Update `series!` logic to accommodate `Axis` types
 - Moved `axis` length validations to `set_axis!`
 - Refactored duplicate `axis` validation and generalized logic under `append_axis!` 

#### Options/dict

 - Changed `Named Tuple` returns with typed returns based on `Options` subtypes
 - Updated all `dict` usages to `Options`
 - Updated logic associated with parsing and collecting `Plot`, `Series` and `DataAttrs` options

#### Grid dimensions

 - Updated `EChart` width and height property types to `GridDimension` to accommodate both `String` and `Int` values for dimensions
 - Updated method `show` to parse GridDimension values according to their type

#### 

### Removed

#### Options

 - Removed `dict` based methods over `Series`, `Plot` and `DataAttrs`
 - Removed `ECharts/Dict.jl` in favor of `ECharts/Options.jl`

### Other

#### Documentation

 - Added examples to docs notebook
 - (WIP) Added light documentation to readme

#### Code

 - Added some docstrings to structures and methods
 - Improved some variable naming on iteration loops for improved code readability
 - Altered size verifications similar to `length(object) != 0` to `!isempty(object)`
 - Removed empty ternary operators

#### Series

 - Generalized `axis_len` verifications and removed duplicate code
 
#### Misc

 - Updated .gitignore
 - Added Manifest.toml to .gitignore as there are no pinned packages or apparent version restrictions on declared dependencies
 - Removed Manifest.toml from commits
 
### Considerations and discussion of changes

#### Axis

Axis are an integral part of the inner workings of the library and are manipulated extensively in different methods.

However, as they exist under an `options dictionary`, most operations require searching for the corresponding axis under an object's `options` - `echart.options["xAxis"], echart.options["yAxis"] or echart["yAxis"]`. 

Promoting Axis to some degree of `first-class citizenship` would enable multiple-dispatch and improve the ability to split different axis operations into different methods, would allow `Axis types` to be used both as method argument or result, as well as enable additional abstractions over structures that use and manipulate `axis`, such as `Series`, `SeriesOptions` or `EChart`.

For instance, to obtain `xAxis` and `yAxis` from an `EChart instance`:  `echart[xAxis]; echart[yAxis]`. 
To `set or push` to an `Axis`: `echart[xAxis] = [Dict(...)]; push!(echart[yAxis], axisdata...)`
To define methods that operate over specific Axis `function some_operation(object, axis::Type{xAxis})`

A more structured approach, similar to what is already implemented with `DataAttrs` could also be considered, if deemed reasonable, where an `Axis` would be a concrete type, composed of a dictionary of options and values.

#### Options

Current implementation uses methods named `dict` to iterate over a `Plot`, `Series` or `DataAttrs` and retrieve/build important chart configurations, such as the axis.

The approach is very sound and the usage of named tuples eases the process of accessing data fields provided by the methods, however, method naming and returns are inconsistent. Also, changing the implementation to work over Base.Dict and returning dictionaries would lose the clear benefits of using named tuples and would make it harder to clearly understand the properties/fields returned, as these also differ according to the input object. 

Building on the structured approach of the named tuple, proposal is to introduce a `type Options` and a set of concrete subtypes `PlotOptions`, `SeriesOptions` and `DataOptions` that keep the structure and property naming of the `tuple`. 
The current `dict` methods are replaced with a `Options methods`, that implement parsing logic and construct the appropriate `options object`. 

The type approach would also allow `option objects` to be incorporated into other structures or be used as arguments/types for multiple dispatch, which is harder to accomplish with named tuples.

#### Series and EChart definitions

Current implementation, mostly, assumes that both `series` or `chart` axis data is always passed as two separate arrays.

`echarts.js` allows and [encourages](https://echarts.apache.org/handbook/en/concepts/dataset/#dataset) the usage of other forms of conveying dataset data, especially for `v5`.

Though, to some extent, it is currently possible to define data using datasets or other properties, it requires users to tap into the inner workings of the objects and directly manipulate `series`, `options` and `axis`. It also requires in some cases, the creation of mockup `charts` or `plots`, that are later manually edited. 

For instance, a chart is initiated `ec = EChart("bar", ["A"], [1])` and later the initial dataset `["A", 1]`, as well as the corresponding series and axis, are removed from the chart's options.

Allowing more loose definitions of `series` and `charts` would reduce the need for these manual changes and allow users to take increased advantage of the powerful mechanisms of the `echarts` library.
 
#### Versioning and v5 compatibility

Current implementation supports version `v"4.6.0-"` and applications may have already been built on top of this version and current Namtso features. 

Most will continue to work even after major echarts upgrades. However, some changes will inevitably lead users to search for newer features and attempt to use the most recent versions of the `echarts API`. 

For instance, under `v5` there's a possibility to define declarative dataset transformations under a chart's `options` which, under `v4+` required usage of additional `javascript` from `echarts.dataTools` [Data Transform](https://echarts.apache.org/handbook/en/concepts/data-transform/#data-transform)

Once there is a need to update `Namtso` to work with `echarts v5`, some methods, options and API usages may become obsolete, and, should the codebase differ, future tags/releases should describe the `echarts` version(s) supported.
[echarts v5 upgrade guide](https://echarts.apache.org/handbook/en/basics/release-note/v5-upgrade-guide/)

#### Compatibility tests

Current changes were tested against the documented examples and a single application comprised of both a small set of standard and customized charts.

Further testing is required to determine whether previously provided features and API behaviour is intact and does not introduce unexpected results or side-effects. Should errors or unexpected behaviour occur, it's important to assess whether they can be fixed with minimal user code changes or if the proposed changes irreparably conflict with current library usage and use-cases. 