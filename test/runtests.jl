using Test, PlotReferenceImages

@testset "PlotReferenceImages" begin
    @test isdir(reference_path(:notabackend, v"1"))
    @test isfile(reference_file(:gr, v"1"))
end
