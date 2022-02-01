const OptionTypes = Dict{String, Any}
const AxisTypes   = Union{Number, Date, AbstractString}

"""
    DataAttrs
"""
struct DataAttrs
    data::Vector{T} where T<:AxisTypes
end

const SeriesData = Vector{DataAttrs}

"""
    Series
"""
mutable struct Series
    plot_type::String
    name::String
    data::SeriesData
    options::OptionTypes
end

"""
    Series(kind::String; name, kwargs...)

Define a Series object with empty `data`

Data and naming for this type of series will be provided through other charts definitions, e.g. `dataset`
"""
function Series(kind::String; name::String="", kwargs...)
    return Series(kind, name, Vector{DataAttrs}(), Dict{String, Any}(kwargs...))
end

"""
    Plot
"""
mutable struct Plot
    series::Vector{Series} 
    options::OptionTypes
    
    function Plot()
        return new(Vector{Series}(), Dict{String, Any}())
    end
    function Plot(series::Vector{Series}, options::Dict)
        return new(series, dict_any(options))
    end
end

"""
    dict_any(d::Dict)

Convert an input dictionary to `Dict{String, Any}`
Also recursively convert all dict values to `Dict{String, Any}` 
"""
function dict_any(d::Dict)
    d = convert(Dict{String, Any}, d)
    for (k,v) in d
        if v isa Dict d[k] = dict_any(v) end
    end
    return d
end
