GridDimension  = Union{String, Int64}
DEFAULT_WIDTH  = 800
DEFAULT_HEIGHT = 600

const BASE_OPTIONS = ["angleAxis", "animation", "aria", "axisPointer", "backgroundColor", "brush", "color", "dataset", "dataZoom", "graphic", "grid", "height", "legend", "parallel", "parallelAxis", "radiusAxis", "singleAxis", "textStyle", "timeline", "title", "toolbox", "tooltip", "visualMap", "width", "xAxis", "yAxis"]

abstract type Renderer end
abstract type Canvas <: Renderer end
abstract type SVG    <: Renderer end

Base.string(::Type{Canvas}) = "canvas"
Base.string(::Type{SVG})    = "svg"

"""
    Axis
"""
abstract type Axis  end
"""
    xAxis
"""
abstract type xAxis <:Axis end
"""
    yAxis
"""
abstract type yAxis <:Axis end

Base.string(::Type{xAxis}) = "xAxis"
Base.string(::Type{yAxis}) = "yAxis"

function Base.getindex(series::Series, index::Axis)
    return ec.options[string(index)]
end

