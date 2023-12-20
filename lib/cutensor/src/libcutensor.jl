using CEnum

# CUTENSOR uses CUDA runtime objects, which are compatible with our driver usage
const cudaStream_t = CUstream

# outlined functionality to avoid GC frame allocation
@noinline function throw_api_error(res)
    if res == CUTENSOR_STATUS_ALLOC_FAILED
        throw(OutOfGPUMemoryError())
    else
        throw(CUTENSORError(res))
    end
end

function check(f, errs...)
    res = retry_reclaim(in((CUTENSOR_STATUS_ALLOC_FAILED, errs...))) do
        return f()
    end

    if res != CUTENSOR_STATUS_SUCCESS
        throw_api_error(res)
    end

    return
end

@cenum cutensorDataType_t::UInt32 begin
    CUTENSOR_R_16F = 2
    CUTENSOR_C_16F = 6
    CUTENSOR_R_16BF = 14
    CUTENSOR_C_16BF = 15
    CUTENSOR_R_32F = 0
    CUTENSOR_C_32F = 4
    CUTENSOR_R_64F = 1
    CUTENSOR_C_64F = 5
    CUTENSOR_R_4I = 16
    CUTENSOR_C_4I = 17
    CUTENSOR_R_4U = 18
    CUTENSOR_C_4U = 19
    CUTENSOR_R_8I = 3
    CUTENSOR_C_8I = 7
    CUTENSOR_R_8U = 8
    CUTENSOR_C_8U = 9
    CUTENSOR_R_16I = 20
    CUTENSOR_C_16I = 21
    CUTENSOR_R_16U = 22
    CUTENSOR_C_16U = 23
    CUTENSOR_R_32I = 10
    CUTENSOR_C_32I = 11
    CUTENSOR_R_32U = 12
    CUTENSOR_C_32U = 13
    CUTENSOR_R_64I = 24
    CUTENSOR_C_64I = 25
    CUTENSOR_R_64U = 26
    CUTENSOR_C_64U = 27
end

@cenum cutensorOperator_t::UInt32 begin
    CUTENSOR_OP_IDENTITY = 1
    CUTENSOR_OP_SQRT = 2
    CUTENSOR_OP_RELU = 8
    CUTENSOR_OP_CONJ = 9
    CUTENSOR_OP_RCP = 10
    CUTENSOR_OP_SIGMOID = 11
    CUTENSOR_OP_TANH = 12
    CUTENSOR_OP_EXP = 22
    CUTENSOR_OP_LOG = 23
    CUTENSOR_OP_ABS = 24
    CUTENSOR_OP_NEG = 25
    CUTENSOR_OP_SIN = 26
    CUTENSOR_OP_COS = 27
    CUTENSOR_OP_TAN = 28
    CUTENSOR_OP_SINH = 29
    CUTENSOR_OP_COSH = 30
    CUTENSOR_OP_ASIN = 31
    CUTENSOR_OP_ACOS = 32
    CUTENSOR_OP_ATAN = 33
    CUTENSOR_OP_ASINH = 34
    CUTENSOR_OP_ACOSH = 35
    CUTENSOR_OP_ATANH = 36
    CUTENSOR_OP_CEIL = 37
    CUTENSOR_OP_FLOOR = 38
    CUTENSOR_OP_MISH = 39
    CUTENSOR_OP_SWISH = 40
    CUTENSOR_OP_SOFT_PLUS = 41
    CUTENSOR_OP_SOFT_SIGN = 42
    CUTENSOR_OP_ADD = 3
    CUTENSOR_OP_MUL = 5
    CUTENSOR_OP_MAX = 6
    CUTENSOR_OP_MIN = 7
    CUTENSOR_OP_UNKNOWN = 126
end

@cenum cutensorStatus_t::UInt32 begin
    CUTENSOR_STATUS_SUCCESS = 0
    CUTENSOR_STATUS_NOT_INITIALIZED = 1
    CUTENSOR_STATUS_ALLOC_FAILED = 3
    CUTENSOR_STATUS_INVALID_VALUE = 7
    CUTENSOR_STATUS_ARCH_MISMATCH = 8
    CUTENSOR_STATUS_MAPPING_ERROR = 11
    CUTENSOR_STATUS_EXECUTION_FAILED = 13
    CUTENSOR_STATUS_INTERNAL_ERROR = 14
    CUTENSOR_STATUS_NOT_SUPPORTED = 15
    CUTENSOR_STATUS_LICENSE_ERROR = 16
    CUTENSOR_STATUS_CUBLAS_ERROR = 17
    CUTENSOR_STATUS_CUDA_ERROR = 18
    CUTENSOR_STATUS_INSUFFICIENT_WORKSPACE = 19
    CUTENSOR_STATUS_INSUFFICIENT_DRIVER = 20
    CUTENSOR_STATUS_IO_ERROR = 21
end

@cenum cutensorAlgo_t::Int32 begin
    CUTENSOR_ALGO_DEFAULT_PATIENT = -6
    CUTENSOR_ALGO_GETT = -4
    CUTENSOR_ALGO_TGETT = -3
    CUTENSOR_ALGO_TTGT = -2
    CUTENSOR_ALGO_DEFAULT = -1
end

@cenum cutensorWorksizePreference_t::UInt32 begin
    CUTENSOR_WORKSPACE_MIN = 1
    CUTENSOR_WORKSPACE_DEFAULT = 2
    CUTENSOR_WORKSPACE_MAX = 3
end

mutable struct cutensorComputeDescriptor end

const cutensorComputeDescriptor_t = Ptr{cutensorComputeDescriptor}

@cenum cutensorOperationDescriptorAttribute_t::UInt32 begin
    CUTENSOR_OPERATION_DESCRIPTOR_TAG = 0
    CUTENSOR_OPERATION_DESCRIPTOR_SCALAR_TYPE = 1
    CUTENSOR_OPERATION_DESCRIPTOR_FLOPS = 2
    CUTENSOR_OPERATION_DESCRIPTOR_MOVED_BYTES = 3
    CUTENSOR_OPERATION_DESCRIPTOR_PADDING_LEFT = 4
    CUTENSOR_OPERATION_DESCRIPTOR_PADDING_RIGHT = 5
    CUTENSOR_OPERATION_DESCRIPTOR_PADDING_VALUE = 6
end

@cenum cutensorPlanPreferenceAttribute_t::UInt32 begin
    CUTENSOR_PLAN_PREFERENCE_AUTOTUNE_MODE = 0
    CUTENSOR_PLAN_PREFERENCE_CACHE_MODE = 1
    CUTENSOR_PLAN_PREFERENCE_INCREMENTAL_COUNT = 2
    CUTENSOR_PLAN_PREFERENCE_ALGO = 3
    CUTENSOR_PLAN_PREFERENCE_KERNEL_RANK = 4
    CUTENSOR_PLAN_PREFERENCE_JIT = 5
end

@cenum cutensorAutotuneMode_t::UInt32 begin
    CUTENSOR_AUTOTUNE_MODE_NONE = 0
    CUTENSOR_AUTOTUNE_MODE_INCREMENTAL = 1
end

@cenum cutensorJitMode_t::UInt32 begin
    CUTENSOR_JIT_MODE_NONE = 0
    CUTENSOR_JIT_MODE_DEFAULT = 1
end

@cenum cutensorCacheMode_t::UInt32 begin
    CUTENSOR_CACHE_MODE_NONE = 0
    CUTENSOR_CACHE_MODE_PEDANTIC = 1
end

@cenum cutensorPlanAttribute_t::UInt32 begin
    CUTENSOR_PLAN_REQUIRED_WORKSPACE = 0
end

mutable struct cutensorOperationDescriptor end

const cutensorOperationDescriptor_t = Ptr{cutensorOperationDescriptor}

mutable struct cutensorPlan end

const cutensorPlan_t = Ptr{cutensorPlan}

mutable struct cutensorPlanPreference end

const cutensorPlanPreference_t = Ptr{cutensorPlanPreference}

mutable struct cutensorHandle end

const cutensorHandle_t = Ptr{cutensorHandle}

mutable struct cutensorTensorDescriptor end

const cutensorTensorDescriptor_t = Ptr{cutensorTensorDescriptor}

# typedef void ( * cutensorLoggerCallback_t ) ( int32_t logLevel , const char * functionName , const char * message )
const cutensorLoggerCallback_t = Ptr{Cvoid}

@checked function cutensorCreate(handle)
    initialize_context()
    @ccall libcutensor.cutensorCreate(handle::Ptr{cutensorHandle_t})::cutensorStatus_t
end

@checked function cutensorDestroy(handle)
    initialize_context()
    @ccall libcutensor.cutensorDestroy(handle::cutensorHandle_t)::cutensorStatus_t
end

@checked function cutensorHandleResizePlanCache(handle, numEntries)
    initialize_context()
    @ccall libcutensor.cutensorHandleResizePlanCache(handle::cutensorHandle_t,
                                                     numEntries::UInt32)::cutensorStatus_t
end

@checked function cutensorHandleWritePlanCacheToFile(handle, filename)
    initialize_context()
    @ccall libcutensor.cutensorHandleWritePlanCacheToFile(handle::cutensorHandle_t,
                                                          filename::Ptr{Cchar})::cutensorStatus_t
end

@checked function cutensorHandleReadPlanCacheFromFile(handle, filename, numCachelinesRead)
    initialize_context()
    @ccall libcutensor.cutensorHandleReadPlanCacheFromFile(handle::cutensorHandle_t,
                                                           filename::Ptr{Cchar},
                                                           numCachelinesRead::Ptr{UInt32})::cutensorStatus_t
end

@checked function cutensorWriteKernelCacheToFile(handle, filename)
    initialize_context()
    @ccall libcutensor.cutensorWriteKernelCacheToFile(handle::cutensorHandle_t,
                                                      filename::Ptr{Cchar})::cutensorStatus_t
end

@checked function cutensorReadKernelCacheFromFile(handle, filename)
    initialize_context()
    @ccall libcutensor.cutensorReadKernelCacheFromFile(handle::cutensorHandle_t,
                                                       filename::Ptr{Cchar})::cutensorStatus_t
end

@checked function cutensorCreateTensorDescriptor(handle, desc, numModes, extent, stride,
                                                 dataType, alignmentRequirement)
    initialize_context()
    @ccall libcutensor.cutensorCreateTensorDescriptor(handle::cutensorHandle_t,
                                                      desc::Ptr{cutensorTensorDescriptor_t},
                                                      numModes::UInt32, extent::Ptr{Int64},
                                                      stride::Ptr{Int64},
                                                      dataType::cutensorDataType_t,
                                                      alignmentRequirement::UInt32)::cutensorStatus_t
end

@checked function cutensorDestroyTensorDescriptor(desc)
    initialize_context()
    @ccall libcutensor.cutensorDestroyTensorDescriptor(desc::cutensorTensorDescriptor_t)::cutensorStatus_t
end

@checked function cutensorCreateElementwiseTrinary(handle, desc, descA, modeA, opA, descB,
                                                   modeB, opB, descC, modeC, opC, descD,
                                                   modeD, opAB, opABC, descCompute)
    initialize_context()
    @ccall libcutensor.cutensorCreateElementwiseTrinary(handle::cutensorHandle_t,
                                                        desc::Ptr{cutensorOperationDescriptor_t},
                                                        descA::cutensorTensorDescriptor_t,
                                                        modeA::Ptr{Int32},
                                                        opA::cutensorOperator_t,
                                                        descB::cutensorTensorDescriptor_t,
                                                        modeB::Ptr{Int32},
                                                        opB::cutensorOperator_t,
                                                        descC::cutensorTensorDescriptor_t,
                                                        modeC::Ptr{Int32},
                                                        opC::cutensorOperator_t,
                                                        descD::cutensorTensorDescriptor_t,
                                                        modeD::Ptr{Int32},
                                                        opAB::cutensorOperator_t,
                                                        opABC::cutensorOperator_t,
                                                        descCompute::cutensorComputeDescriptor_t)::cutensorStatus_t
end

@checked function cutensorElementwiseTrinaryExecute(handle, plan, alpha, A, beta, B, gamma,
                                                    C, D, stream)
    initialize_context()
    @ccall libcutensor.cutensorElementwiseTrinaryExecute(handle::cutensorHandle_t,
                                                         plan::cutensorPlan_t,
                                                         alpha::Ptr{Cvoid}, A::CuPtr{Cvoid},
                                                         beta::Ptr{Cvoid}, B::CuPtr{Cvoid},
                                                         gamma::Ptr{Cvoid}, C::CuPtr{Cvoid},
                                                         D::CuPtr{Cvoid},
                                                         stream::cudaStream_t)::cutensorStatus_t
end

@checked function cutensorCreateElementwiseBinary(handle, desc, descA, modeA, opA, descC,
                                                  modeC, opC, descD, modeD, opAC,
                                                  descCompute)
    initialize_context()
    @ccall libcutensor.cutensorCreateElementwiseBinary(handle::cutensorHandle_t,
                                                       desc::Ptr{cutensorOperationDescriptor_t},
                                                       descA::cutensorTensorDescriptor_t,
                                                       modeA::Ptr{Int32},
                                                       opA::cutensorOperator_t,
                                                       descC::cutensorTensorDescriptor_t,
                                                       modeC::Ptr{Int32},
                                                       opC::cutensorOperator_t,
                                                       descD::cutensorTensorDescriptor_t,
                                                       modeD::Ptr{Int32},
                                                       opAC::cutensorOperator_t,
                                                       descCompute::cutensorComputeDescriptor_t)::cutensorStatus_t
end

@checked function cutensorElementwiseBinaryExecute(handle, plan, alpha, A, gamma, C, D,
                                                   stream)
    initialize_context()
    @ccall libcutensor.cutensorElementwiseBinaryExecute(handle::cutensorHandle_t,
                                                        plan::cutensorPlan_t,
                                                        alpha::Ptr{Cvoid}, A::CuPtr{Cvoid},
                                                        gamma::Ptr{Cvoid}, C::CuPtr{Cvoid},
                                                        D::CuPtr{Cvoid},
                                                        stream::cudaStream_t)::cutensorStatus_t
end

@checked function cutensorCreatePermutation(handle, desc, descA, modeA, opA, descB, modeB,
                                            descCompute)
    initialize_context()
    @ccall libcutensor.cutensorCreatePermutation(handle::cutensorHandle_t,
                                                 desc::Ptr{cutensorOperationDescriptor_t},
                                                 descA::cutensorTensorDescriptor_t,
                                                 modeA::Ptr{Int32}, opA::cutensorOperator_t,
                                                 descB::cutensorTensorDescriptor_t,
                                                 modeB::Ptr{Int32},
                                                 descCompute::cutensorComputeDescriptor_t)::cutensorStatus_t
end

@checked function cutensorPermute(handle, plan, alpha, A, B, stream)
    initialize_context()
    @ccall libcutensor.cutensorPermute(handle::cutensorHandle_t, plan::cutensorPlan_t,
                                       alpha::Ptr{Cvoid}, A::CuPtr{Cvoid}, B::CuPtr{Cvoid},
                                       stream::cudaStream_t)::cutensorStatus_t
end

@checked function cutensorCreateContraction(handle, desc, descA, modeA, opA, descB, modeB,
                                            opB, descC, modeC, opC, descD, modeD,
                                            descCompute)
    initialize_context()
    @ccall libcutensor.cutensorCreateContraction(handle::cutensorHandle_t,
                                                 desc::Ptr{cutensorOperationDescriptor_t},
                                                 descA::cutensorTensorDescriptor_t,
                                                 modeA::Ptr{Int32}, opA::cutensorOperator_t,
                                                 descB::cutensorTensorDescriptor_t,
                                                 modeB::Ptr{Int32}, opB::cutensorOperator_t,
                                                 descC::cutensorTensorDescriptor_t,
                                                 modeC::Ptr{Int32}, opC::cutensorOperator_t,
                                                 descD::cutensorTensorDescriptor_t,
                                                 modeD::Ptr{Int32},
                                                 descCompute::cutensorComputeDescriptor_t)::cutensorStatus_t
end

@checked function cutensorDestroyOperationDescriptor(desc)
    initialize_context()
    @ccall libcutensor.cutensorDestroyOperationDescriptor(desc::cutensorOperationDescriptor_t)::cutensorStatus_t
end

@checked function cutensorOperationDescriptorSetAttribute(handle, desc, attr, buf,
                                                          sizeInBytes)
    initialize_context()
    @ccall libcutensor.cutensorOperationDescriptorSetAttribute(handle::cutensorHandle_t,
                                                               desc::cutensorOperationDescriptor_t,
                                                               attr::cutensorOperationDescriptorAttribute_t,
                                                               buf::Ptr{Cvoid},
                                                               sizeInBytes::Csize_t)::cutensorStatus_t
end

@checked function cutensorOperationDescriptorGetAttribute(handle, desc, attr, buf,
                                                          sizeInBytes)
    initialize_context()
    @ccall libcutensor.cutensorOperationDescriptorGetAttribute(handle::cutensorHandle_t,
                                                               desc::cutensorOperationDescriptor_t,
                                                               attr::cutensorOperationDescriptorAttribute_t,
                                                               buf::Ptr{Cvoid},
                                                               sizeInBytes::Csize_t)::cutensorStatus_t
end

@checked function cutensorCreatePlanPreference(handle, pref, algo, jitMode)
    initialize_context()
    @ccall libcutensor.cutensorCreatePlanPreference(handle::cutensorHandle_t,
                                                    pref::Ptr{cutensorPlanPreference_t},
                                                    algo::cutensorAlgo_t,
                                                    jitMode::cutensorJitMode_t)::cutensorStatus_t
end

@checked function cutensorDestroyPlanPreference(pref)
    initialize_context()
    @ccall libcutensor.cutensorDestroyPlanPreference(pref::cutensorPlanPreference_t)::cutensorStatus_t
end

@checked function cutensorPlanPreferenceSetAttribute(handle, pref, attr, buf, sizeInBytes)
    initialize_context()
    @ccall libcutensor.cutensorPlanPreferenceSetAttribute(handle::cutensorHandle_t,
                                                          pref::cutensorPlanPreference_t,
                                                          attr::cutensorPlanPreferenceAttribute_t,
                                                          buf::Ptr{Cvoid},
                                                          sizeInBytes::Csize_t)::cutensorStatus_t
end

@checked function cutensorPlanGetAttribute(handle, plan, attr, buf, sizeInBytes)
    initialize_context()
    @ccall libcutensor.cutensorPlanGetAttribute(handle::cutensorHandle_t,
                                                plan::cutensorPlan_t,
                                                attr::cutensorPlanAttribute_t,
                                                buf::Ptr{Cvoid},
                                                sizeInBytes::Csize_t)::cutensorStatus_t
end

@checked function cutensorEstimateWorkspaceSize(handle, desc, planPref, workspacePref,
                                                workspaceSizeEstimate)
    initialize_context()
    @ccall libcutensor.cutensorEstimateWorkspaceSize(handle::cutensorHandle_t,
                                                     desc::cutensorOperationDescriptor_t,
                                                     planPref::cutensorPlanPreference_t,
                                                     workspacePref::cutensorWorksizePreference_t,
                                                     workspaceSizeEstimate::Ptr{UInt64})::cutensorStatus_t
end

@checked function cutensorCreatePlan(handle, plan, desc, pref, workspaceSizeLimit)
    initialize_context()
    @ccall libcutensor.cutensorCreatePlan(handle::cutensorHandle_t,
                                          plan::Ptr{cutensorPlan_t},
                                          desc::cutensorOperationDescriptor_t,
                                          pref::cutensorPlanPreference_t,
                                          workspaceSizeLimit::UInt64)::cutensorStatus_t
end

@checked function cutensorDestroyPlan(plan)
    initialize_context()
    @ccall libcutensor.cutensorDestroyPlan(plan::cutensorPlan_t)::cutensorStatus_t
end

@checked function cutensorContract(handle, plan, alpha, A, B, beta, C, D, workspace,
                                   workspaceSize, stream)
    initialize_context()
    @ccall libcutensor.cutensorContract(handle::cutensorHandle_t, plan::cutensorPlan_t,
                                        alpha::Ptr{Cvoid}, A::CuPtr{Cvoid}, B::CuPtr{Cvoid},
                                        beta::Ptr{Cvoid}, C::CuPtr{Cvoid}, D::CuPtr{Cvoid},
                                        workspace::CuPtr{Cvoid}, workspaceSize::UInt64,
                                        stream::cudaStream_t)::cutensorStatus_t
end

@checked function cutensorCreateReduction(handle, desc, descA, modeA, opA, descC, modeC,
                                          opC, descD, modeD, opReduce, descCompute)
    initialize_context()
    @ccall libcutensor.cutensorCreateReduction(handle::cutensorHandle_t,
                                               desc::Ptr{cutensorOperationDescriptor_t},
                                               descA::cutensorTensorDescriptor_t,
                                               modeA::Ptr{Int32}, opA::cutensorOperator_t,
                                               descC::cutensorTensorDescriptor_t,
                                               modeC::Ptr{Int32}, opC::cutensorOperator_t,
                                               descD::cutensorTensorDescriptor_t,
                                               modeD::Ptr{Int32},
                                               opReduce::cutensorOperator_t,
                                               descCompute::cutensorComputeDescriptor_t)::cutensorStatus_t
end

@checked function cutensorReduce(handle, plan, alpha, A, beta, C, D, workspace,
                                 workspaceSize, stream)
    initialize_context()
    @ccall libcutensor.cutensorReduce(handle::cutensorHandle_t, plan::cutensorPlan_t,
                                      alpha::Ptr{Cvoid}, A::CuPtr{Cvoid}, beta::Ptr{Cvoid},
                                      C::CuPtr{Cvoid}, D::CuPtr{Cvoid},
                                      workspace::CuPtr{Cvoid}, workspaceSize::UInt64,
                                      stream::cudaStream_t)::cutensorStatus_t
end

function cutensorGetErrorString(error)
    @ccall libcutensor.cutensorGetErrorString(error::cutensorStatus_t)::Cstring
end

# no prototype is found for this function at cutensor.h:980:8, please use with caution
function cutensorGetVersion()
    @ccall libcutensor.cutensorGetVersion()::Csize_t
end

# no prototype is found for this function at cutensor.h:986:8, please use with caution
function cutensorGetCudartVersion()
    @ccall libcutensor.cutensorGetCudartVersion()::Csize_t
end

@checked function cutensorLoggerSetCallback(callback)
    initialize_context()
    @ccall libcutensor.cutensorLoggerSetCallback(callback::cutensorLoggerCallback_t)::cutensorStatus_t
end

@checked function cutensorLoggerSetFile(file)
    initialize_context()
    @ccall libcutensor.cutensorLoggerSetFile(file::Ptr{Libc.FILE})::cutensorStatus_t
end

@checked function cutensorLoggerOpenFile(logFile)
    initialize_context()
    @ccall libcutensor.cutensorLoggerOpenFile(logFile::Cstring)::cutensorStatus_t
end

@checked function cutensorLoggerSetLevel(level)
    initialize_context()
    @ccall libcutensor.cutensorLoggerSetLevel(level::Int32)::cutensorStatus_t
end

@checked function cutensorLoggerSetMask(mask)
    initialize_context()
    @ccall libcutensor.cutensorLoggerSetMask(mask::Int32)::cutensorStatus_t
end

# no prototype is found for this function at cutensor.h:1034:18, please use with caution
@checked function cutensorLoggerForceDisable()
    initialize_context()
    @ccall libcutensor.cutensorLoggerForceDisable()::cutensorStatus_t
end

# Skipping MacroDefinition: CUTENSOR_EXTERN extern

# compute descriptors are accessed through external symbols
for desc in [:CUTENSOR_COMPUTE_DESC_16F,
             :CUTENSOR_COMPUTE_DESC_16BF,
             :CUTENSOR_COMPUTE_DESC_TF32,
             :CUTENSOR_COMPUTE_DESC_3XTF32,
             :CUTENSOR_COMPUTE_DESC_32F,
             :CUTENSOR_COMPUTE_DESC_64F]
    @eval begin
        $desc() = cutensorComputeDescriptor_t(cglobal(($(QuoteNode(desc)), libcutensor)))
    end
end
