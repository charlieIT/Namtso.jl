module Namtso

using Dates, JSON, Random

export EChart, series!
export Tools

PUBLIC_SCRIPT = "https://cdnjs.cloudflare.com/ajax/libs/echarts/4.6.0/echarts.min.js"
include("Base.jl")
include("ECharts/ECharts.jl")
include("Tools/BoxPlot.jl")

end # module
