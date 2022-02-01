using Random 
using Statistics

"""
    prepareboxplot(data::Vector; kwargs...)

Obtain boxplot transformed data from an input data vector.

Examples
```julia

data = [880, 880, 880, 860, 720, 720, 620, 860, 970, 950, 880, 910, 850, 870, 840, 840, 850, 840, 840, 840]

prepareboxplot(data, name="Series 1")
#=
(
 axisdata = "Series 1", 
 boxdata = [620.0, 840.0, 855.0, 880.0, 970.0], 
 outliers = Any[Any["Series 1", 620], Any["Series 1", 720], Any["Series 1", 720], Any["Series 1", 950], Any["Series 1", 970]]
)
=#
```
"""
function prepareboxplot(data::Vector{I}; iqrbound=1.5, extremes::Bool=false, name=randstring(2), vertical=true) where I<:Union{Int64, Float64}
    isempty(data) && return (axisdata=name, boxdata=[], outliers=[])
    v   = sort(data)
    mi  = minimum(v)
    q1  = quantile(v, 0.25)
    q2  = quantile(v, 0.5)
    q3  = quantile(v, 0.75)
    ma  = maximum(v)
    med = median(v)
    
    bound = iqrbound * (q3 - q1)
    low   = extremes ? mi  : max(mi, q1 - bound)
    high  = extremes ? max : min(ma, q3 + bound)
    
    outliers_filter = filter(x->x < low || x > high, v)
    outliers = []
    for outlier in outliers_filter
        out = vertical ? [name, outlier] : [outlier, name]
        push!(outliers, out)
    end
    
    return (
            axisdata = name,
            boxdata  = [mi, q1, q2, q3, ma],
            outliers = filter(y->!isempty(y), outliers)
            )
end

"""
    prepareboxplot(dataset::Vector{Vector{T}}; kwargs...) where T<:Union{Int64, Float64}

Given an input `dataset`, Vector of Arrays, apply boxplot transformation to each data entry and return a boxplot oriented dataset

Examples
```julia

dataset = [
        [850, 740, 900, 1070, 930, 850, 950, 980, 980, 880, 1000, 980, 930, 650, 760, 810, 1000, 1000, 960, 960],
        [960, 940, 960, 940, 880, 800, 850, 880, 900, 840, 830, 790, 810, 880, 880, 830, 800, 790, 760, 800],
        [880, 880, 880, 860, 720, 720, 620, 860, 970, 950, 880, 910, 850, 870, 840, 840, 850, 840, 840, 840],
        [890, 810, 810, 820, 800, 770, 760, 740, 750, 760, 910, 920, 890, 860, 880, 720, 840, 850, 850, 780],
        [890, 840, 780, 810, 760, 810, 790, 810, 820, 850, 870, 870, 810, 740, 810, 940, 950, 800, 810, 870],
]

prepared = prepareboxplot(dataset, vertical=false)

#=
(
    axisdata = ["1", "2", "3", "4", "5"], 
    boxdata  = [[650.0, 850.0, 940.0, 980.0, 1070.0], [760.0, 800.0, 845.0, 885.0, 960.0], [620.0, 840.0, 855.0, 880.0, 970.0], [720.0, 767.5, 815.0, 865.0, 920.0], [740.0, 807.5, 810.0, 870.0, 950.0]], 
    outliers = [[650, 1], [620, 3], [720, 3], [720, 3], [950, 3], [970, 3]]
)
=#

prepared = prepareboxplot(dataset, vertical=true)
#=
(
    axisdata = ["1", "2", "3", "4", "5"], 
    boxdata  = [[650.0, 850.0, 940.0, 980.0, 1070.0], [760.0, 800.0, 845.0, 885.0, 960.0], [620.0, 840.0, 855.0, 880.0, 970.0], [720.0, 767.5, 815.0, 865.0, 920.0], [740.0, 807.5, 810.0, 870.0, 950.0]], 
    outliers = [[1, 650], [3, 620], [3, 720], [3, 720], [3, 950], [3, 970]]
)
=#
"""
function prepareboxplot(dataset::Vector{Vector{T}}; kwargs...) where T<:Union{Int64, Float64, Any}
    axisdata = []
    boxdata  = []
    outliers = []
    for (idx, data) in enumerate(dataset)
        nt = prepareboxplot(convert(Vector{Int64}, data); name=idx, kwargs...)
        push!(axisdata, string(idx))
        push!(boxdata,  nt.boxdata)
        append!(outliers, nt.outliers)
    end
    return (axisdata = axisdata, boxdata = boxdata, outliers = filter(y->!isempty(y), outliers))
end