using CUDA.CUSOLVER, CUDA.CUSPARSE

m = 200
n = 100
density = 0.05

@testset "SparseCholesky -- $elty" for elty in [Float32, Float64, ComplexF32, ComplexF64]
    R = real(elty)
    A = sprand(elty, n, n, density)
    A = A * A' + I
    d_A = CuSparseMatrixCSR{elty}(A)
    F = CUSOLVER.SparseCholesky(d_A)
    CUSOLVER.spcholesky_buffer(F, d_A)
    tol = R == Float32 ? R(1e-6) : R(1e-12)
    CUSOLVER.spcholesky_factorise(F, d_A, tol)
    b = rand(elty, n)
    d_b = CuVector(b)
    x = zeros(elty, n)
    d_x = CuVector(x)
    CUSOLVER.spcholesky_solve(F, d_b, d_x)
    d_r = d_b - d_A * d_x
    @test norm(d_A' * d_r) ≤ √eps(R)
    diag = zeros(elty, n)
    d_diag = CuVector{R}(diag)
    CUSOLVER.spcholesky_diag(F, d_diag)
    det_A = mapreduce(x -> x^2, *, d_diag)
    @test det_A ≈ det(Matrix(A))
end

@testset "SparseQR -- $elty" for elty in [Float32, Float64, ComplexF32, ComplexF64]
    R = real(elty)
    A = sprand(elty, m, n, density)
    d_A = CuSparseMatrixCSR{elty}(A)
    F = CUSOLVER.SparseQR(d_A)
    CUSOLVER.spqr_setup(F, d_A)
    CUSOLVER.spqr_buffer(F, d_A)
    tol = R == Float32 ? R(1e-6) : R(1e-12)
    CUSOLVER.spqr_factorise(F, tol)
    b = rand(elty, m)
    d_b = CuVector(b)
    x = zeros(elty, n)
    d_x = CuVector(x)
    CUSOLVER.spqr_solve(F, copy(d_b), d_x)
    d_r = d_b - d_A * d_x
    @test norm(d_A' * d_r) ≤ √eps(R)

    d_B = copy(d_A)
    nnz_B = rand(elty, nnz(d_B))
    d_B.nzVal = CuVector{elty}(nnz_B)
    CUSOLVER.spqr_setup(F, d_B)
    b = rand(elty, m)
    d_b = CuVector(b)
    x = zeros(elty, n)
    d_x = CuVector(x)
    CUSOLVER.spqr_factorise_solve(F, copy(d_b), d_x, tol)
    d_r = d_b - d_B * d_x
    @test norm(d_B' * d_r) ≤ √eps(R)
end
