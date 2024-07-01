const cufftNumber = Union{cufftDoubleReal,cufftReal,Float16,cufftDoubleComplex,cufftComplex,Complex{Float16}}
const cufftReals = Union{cufftDoubleReal,cufftReal,Float16}
const cufftComplexes = Union{cufftDoubleComplex,cufftComplex,Complex{Float16}}
const cufftDouble = Union{cufftDoubleReal,cufftDoubleComplex}
const cufftSingle = Union{cufftReal,cufftComplex}
const cufftTypeDouble = Union{Type{cufftDoubleReal},Type{cufftDoubleComplex}}
const cufftTypeSingle = Union{Type{cufftReal},Type{cufftComplex}}

cufftfloat(x) = _cufftfloat(float(x))
_cufftfloat(::Type{T}) where {T<:cufftReals} = T
_cufftfloat(::Type{Float16}) = Float32
_cufftfloat(::Type{Complex{T}}) where {T} = Complex{_cufftfloat(T)}
_cufftfloat(::Type{T}) where {T} = error("type $T not supported")
_cufftfloat(x::T) where {T} = _cufftfloat(T)(x)

complexfloat(x::DenseCuArray{Complex{<:cufftReals}}) = x
realfloat(x::DenseCuArray{<:cufftReals}) = x

complexfloat(x::DenseCuArray{T}) where {T<:Complex} = copy1(typeof(cufftfloat(zero(T))), x)
complexfloat(x::DenseCuArray{T}) where {T<:Real} = copy1(typeof(complex(cufftfloat(zero(T)))), x)

realfloat(x::DenseCuArray{T}) where {T<:Real} = copy1(typeof(cufftfloat(zero(T))), x)

function copy1(::Type{T}, x) where T
    y = CuArray{T}(undef, map(length, axes(x)))
    #copy!(y, x)
    y .= broadcast(xi->convert(T,xi),x)
end
