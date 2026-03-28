using AstronomicalComputing
using Test

@testset "AstronomicalComputing.jl" begin
    @testset "salta" begin 
        hour, minute, second =fraction_to_hms(0.5)
        println(hour)
        @test hour == 12
    end
end
