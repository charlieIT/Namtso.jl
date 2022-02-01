# init with empty series key to prevent having to constantly check whether it already exists across methods
const DEFAULT_OPTIONS_ECHART = Dict{String, Any}("series"=>[])

"""
    EChart
"""
Base.@kwdef mutable struct EChart
    options::OptionTypes       = deepcopy(DEFAULT_OPTIONS_ECHART)
    width::GridDimension       = deepcopy(DEFAULT_WIDTH)
    height::GridDimension      = deepcopy(DEFAULT_HEIGHT)
    resize::Bool               = false  # do not apply container reactivity by default, https://echarts.apache.org/handbook/en/concepts/chart-size#reactive-of-the-container-size
    renderer::Type{<:Renderer} = Canvas # default to 'canvas', as per https://echarts.apache.org/handbook/en/best-practices/canvas-vs-svg/
    id::String                 = randstring(10)
end

"""
    EChart(plot::Plot; kwargs...)

Generate EChart from a Plot definition

Automatically invoked by the more generic, series oriented, constructor

Examples
```julia
```
"""
function EChart(plot::Plot; id::String = randstring(10), resize::Bool = false, renderer::Type{R} = Canvas) where R<:Renderer
        
    plot_options = Options(plot)
    width  = get(plot_options.options, "width",  DEFAULT_WIDTH)
    height = get(plot_options.options, "height", DEFAULT_HEIGHT)
    
    delete!(plot_options.options, "width")
    delete!(plot_options.options, "height")
    
    return EChart(
            id       = id, 
            options  = dict_any(plot_options.options), 
            width    = width, 
            height   = height, 
            resize   = resize, 
            renderer = renderer)
end

"""
    EChart(kind::String, args...; kwargs...)

Build an EChart with a set of Series given by `args`

Series type is defined by `kind`
"""
function EChart(kind::String, args...; id::String=randstring(10), resize = false, renderer = Canvas, kwargs...)

    series_options = Dict()
    chart_options  = Dict()
    
    for (k,v) in kwargs
       k = string(k)
       if k in BASE_OPTIONS
           chart_options[k] = v
       else
           series_options[k] = v 
       end
    end
    
    data = Vector{DataAttrs}() 
    
    if length(args) > 2 # multiple series
        
    elseif length(args) == 2
        data = Vector{DataAttrs}([DataAttrs(arg) for arg in args])
    end
    series = Series(kind, "Series1", data, series_options)
    plot = Plot([series], chart_options)
    
    return EChart(plot, resize = resize, renderer = renderer)
end

function Base.getindex(ec::EChart, i::String)
    if i in ["width", "height"]
        return Base.getproperty(ec, Symbol(i))
    else
        return Base.getindex(ec.options, i)
    end
end
Base.getindex(ec::EChart, axis::Type{A}) where A<:Axis = Base.getindex(ec, string(axis))

function Base.setindex!(ec::EChart, v, i::String)
    if i in ["width", "heigth"]
        Base.setproperty!(ec, Symbol(i), v)
    else 
        Base.setindex!(ec.options, v, i)
    end
end

function Base.setindex!(ec::EChart, v, i::A) where A<:Axis
    Base.setindex!(ec.options, v, string(i))
end