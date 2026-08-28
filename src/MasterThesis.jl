module MasterThesis

using NCDatasets
using CairoMakie

include("constants.jl")
export RE

include("plot/plot_results.jl")
export plot_ElectronFlux, plot_all_ElectronFlux
export plot_ColumnExcitation, plot_ColumnExcitationRatio
export plot_VolumExcitation
export plot_IeE_updown

include("plot/plot_quicklook.jl")
export generate_figures


end
